import React from "react";
import { useQuery, useMutation } from "@apollo/react-hooks";
import { Card, CardHeader, CardBody, CardFooter } from "reactstrap";
import { recommendationsDataMap } from "./recommendationsDataMap";
import {
  GET_RECOMMENDATIONS,
  INSERT_RECOMMENDATION,
  UPDATE_RECOMMENDATION,
} from "../../../queries/recommendations";
import RecommendationTextInput from "./RecommendationTextInput";
import RecommendationSelectValueDropdown from "./RecommendationSelectValueDropdown";

// TODOs
// 2. Match styling designs
// 3. Make sure add/edit/cancel buttons align with notes

const Recommendations = ({ crashId }) => {
  // get current users email
  const userEmail = localStorage.getItem("hasura_user_email");

  // fetch recommendation table from database using graphQL query
  const { loading, error, data, refetch } = useQuery(GET_RECOMMENDATIONS, {
    variables: { crashId },
  });

  // declare mutation functions
  const [addRecommendation] = useMutation(INSERT_RECOMMENDATION);
  const [editRecommendation] = useMutation(UPDATE_RECOMMENDATION);

  if (loading) return "Loading...";
  if (error) return `Error! ${error.message}`;

  const fieldConfig = recommendationsDataMap;
  const recommendation = data?.recommendations?.[0];
  const doesRecommendationRecordExist = recommendation ? true : false;
  const recommendationRecordId = recommendation?.id;

  // Get current value from returned data if there is one
  const getLookupValue = ({ lookupOptions, key }) => {
    return recommendation?.[lookupOptions]?.[key] || "";
  };

  const getFieldValue = field => recommendation?.[field] || "";

  const onAdd = valuesObject => {
    const recommendationRecord = {
      crashId,
      userEmail,
      ...valuesObject,
    };

    addRecommendation({
      variables: recommendationRecord,
    })
      .then(() => {
        refetch();
      })
      .catch(error => console.error(error));
  };

  const onEdit = changesObject => {
    editRecommendation({
      variables: {
        id: recommendationRecordId,
        changes: changesObject,
      },
    })
      .then(() => {
        refetch();
      })
      .catch(error => console.error(error));
  };

  return (
    <Card>
      <CardHeader>Fatality Review Board Recommendations</CardHeader>
      <CardBody className="px-1">
        <div className="container-fluid">
          <div className="row border-bottom">
            <div className="col-12 col-lg-6">
              <div className="row">
                <div className="col-auto pr-0">
                  <div className="font-weight-bold pt-1">
                    {fieldConfig.fields.coordination_partner_id.label}
                  </div>
                </div>
                <div className="col-8">
                  <RecommendationSelectValueDropdown
                    value={getLookupValue(
                      fieldConfig.fields.coordination_partner_id
                    )}
                    onOptionClick={
                      doesRecommendationRecordExist ? onEdit : onAdd
                    }
                    options={data.atd__coordination_partners_lkp}
                    field={"coordination_partner_id"}
                  />
                </div>
              </div>
            </div>
            <div className="col-12 col-lg-6">
              <div className="row">
                <div className="col-auto pr-0">
                  <div className="font-weight-bold pt-1">
                    {fieldConfig.fields.recommendation_status_id.label}
                  </div>
                </div>
                <div className="col-8">
                  <RecommendationSelectValueDropdown
                    value={getLookupValue(
                      fieldConfig.fields.recommendation_status_id
                    )}
                    onOptionClick={
                      doesRecommendationRecordExist ? onEdit : onAdd
                    }
                    options={data.atd__recommendation_status_lkp}
                    field={"recommendation_status_id"}
                  />
                </div>
              </div>
            </div>
          </div>
          <div
            className="row border-bottom"
            style={{ paddingTop: "12px", paddingBottom: "12px" }}
          >
            <div className="col-12">
              <RecommendationTextInput
                label={"Recommendation"}
                data={recommendation?.text}
                placeholder={"Enter recommendation here..."}
                existingValue={getFieldValue(fieldConfig.fields.text.key)}
                field={fieldConfig.fields.text.key}
                doesRecommendationRecordExist={doesRecommendationRecordExist}
                onAdd={onAdd}
                onEdit={onEdit}
              />
            </div>
          </div>
          <div
            className="row"
            style={{ paddingTop: "12px", paddingBottom: "12px" }}
          >
            <div className="col-12">
              <RecommendationTextInput
                label={"Updates"}
                data={recommendation?.update}
                placeholder={"Enter updates here..."}
                existingValue={getFieldValue(fieldConfig.fields.update.key)}
                field={fieldConfig.fields.update.key}
                doesRecommendationRecordExist={doesRecommendationRecordExist}
                onAdd={onAdd}
                onEdit={onEdit}
              />
            </div>
          </div>
        </div>
      </CardBody>
      <CardFooter></CardFooter>
    </Card>
  );
};

export default Recommendations;
