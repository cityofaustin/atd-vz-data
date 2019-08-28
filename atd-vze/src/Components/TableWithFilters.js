import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import { useQuery } from "@apollo/react-hooks";
import { gql } from "apollo-boost";
import { withApollo } from "react-apollo";
import { CSVLink } from "react-csv";

import {
  Badge,
  Card,
  CardBody,
  CardHeader,
  Col,
  Row,
  Table,
  ButtonGroup,
  Spinner,
} from "reactstrap";
import TableSearchBar from "./TableSearchBar";
import TableSortHeader from "./TableSortHeader";
import TablePaginationControl from "./TablePaginationControl";

const TableWithFilters = ({
  title,
  defaultQuery,
  filterQuery,
  fieldsToSearch,
  columns,
  dataKey,
  fieldMap,
}) => {
  const [tableQuery, setTableQuery] = useState(defaultQuery);
  // Filter states hold array of objects, [{ KEYWORD: `string that replaces keyword`}]
  const [pageFilter, setPageFilter] = useState("");
  const [orderFilter, setOrderFilter] = useState("");
  const [searchFilter, setSearchFilter] = useState("");
  console.log(tableQuery);

  useEffect(() => {
    // On every render, filterQuery is copied, unset filters are removed, set filters replace keywords in filterQuery
    // Then, a GraphQL query is made from the string and response from DB populates table
    const removeFiltersNotSet = queryWithFilters => {
      let queryWithFiltersCleared = queryWithFilters;
      if (pageFilter === "") {
        queryWithFiltersCleared = queryWithFiltersCleared.replace("OFFSET", "");
        queryWithFiltersCleared = queryWithFiltersCleared.replace("LIMIT", "");
      }
      if (orderFilter === "") {
        queryWithFiltersCleared = queryWithFiltersCleared.replace(
          "ORDER_BY",
          ""
        );
      }
      if (searchFilter === "") {
        queryWithFiltersCleared = queryWithFiltersCleared.replace("SEARCH", "");
      }
      return queryWithFiltersCleared;
    };

    const createQuery = () => {
      let queryWithFilters = filterQuery;
      queryWithFilters = removeFiltersNotSet(queryWithFilters);
      if (pageFilter === "" && orderFilter === "") {
        setTableQuery(defaultQuery);
      } else {
        if (pageFilter !== "") {
          pageFilter.forEach(query => {
            queryWithFilters = queryWithFilters.replace(
              Object.keys(query),
              Object.values(query)
            );
          });
        }
        if (orderFilter !== "") {
          orderFilter.forEach(query => {
            queryWithFilters = queryWithFilters.replace(
              Object.keys(query),
              Object.values(query)
            );
          });
        }
        if (searchFilter !== "") {
          searchFilter.forEach(query => {
            queryWithFilters = queryWithFilters.replace(
              Object.keys(query),
              Object.values(query)
            );
          });
        }
        setTableQuery(queryWithFilters);
      }
    };
    createQuery();
  }, [
    pageFilter,
    orderFilter,
    searchFilter,
    tableQuery,
    defaultQuery,
    filterQuery,
  ]);

  const { loading, error, data } = useQuery(
    gql`
      ${tableQuery}
    `
  );

  if (error) return `Error! ${error.message}`;

  const clearFilters = () => {
    setPageFilter("");
    setOrderFilter("");
    setSearchFilter("");
  };

  return (
    <div className="animated fadeIn">
      <Row>
        <Col>
          <Card>
            <CardHeader>
              <i className="fa fa-car" /> {title}
            </CardHeader>
            <CardBody>
              <TableSearchBar
                fieldsToSearch={fieldsToSearch}
                setSearchFilter={setSearchFilter}
                clearFilters={clearFilters}
              />
              <ButtonGroup className="mb-2 float-right">
                <TablePaginationControl
                  responseDataSet={"atd_txdot_crashes"}
                  setPageFilter={setPageFilter}
                />{" "}
                {data[dataKey] && (
                  <CSVLink
                    className=""
                    data={data[dataKey]}
                    filename={dataKey + Date.now()}
                  >
                    <i className="fa fa-save fa-2x ml-2 mt-1" />
                  </CSVLink>
                )}
              </ButtonGroup>
              <Table responsive>
                <TableSortHeader
                  columns={columns}
                  setOrderFilter={setOrderFilter}
                  fieldMap={fieldMap}
                />
                <tbody>
                  {loading ? (
                    <Spinner className="mt-2" color="primary" />
                  ) : (
                    data &&
                    data[dataKey].map(crash => (
                      <tr key={crash.crash_id}>
                        <td>
                          <Link to={`crashes/${crash.crash_id}`}>
                            {crash.crash_id}
                          </Link>
                        </td>
                        <td>{crash.crash_date}</td>
                        <td>{`${crash.rpt_street_pfx} ${crash.rpt_street_name} ${crash.rpt_street_sfx}`}</td>
                        <td>
                          <Badge color="warning">{crash.tot_injry_cnt}</Badge>
                        </td>
                        <td>
                          <Badge color="danger">{crash.death_cnt}</Badge>
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </Table>
            </CardBody>
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default withApollo(TableWithFilters);
