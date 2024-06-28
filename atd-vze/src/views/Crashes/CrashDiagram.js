import React, { useState } from "react";
import {
  Card,
  CardHeader,
  CardBody,
  CardFooter,
  Button,
  ButtonGroup,
  Col,
  Row,
  UncontrolledTooltip,
} from "reactstrap";
import axios from "axios";
import { TransformWrapper, TransformComponent } from "react-zoom-pan-pinch";
import { isDev } from "../../helpers/environment";

const CrashDiagram = ({
  crashId,
  isCr3Stored,
  isTempRecord,
  cr3FileMetadata,
}) => {
  const [rotation, setRotation] = useState(0);

  // Set S3 folder for diagram depending on environment
  const s3Folder =
    process.env.NODE_ENV === "production" || isDev ? "production" : "staging";

  const requestCR3 = () => {
    const requestUrl = `${process.env.REACT_APP_CR3_API_DOMAIN}/cr3/download/${crashId}`;
    const token = window.localStorage.getItem("id_token");

    axios
      .request(requestUrl, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      .then(res => {
        const win = window.open(res.data.message, "_blank");
        win.focus();
      });
  };

  const rotate = event => {
    setRotation(event.target.value);
  };

  const resetRotate = () => {
    setRotation(0);
  };

  return (
    <Card className="h-100 my-auto">
      <CardHeader>
        <Row className="d-flex align-items-center">
          <Col>Crash Diagram</Col>
          <Col className="d-flex justify-content-end">
            {isCr3Stored ? (
              <Button color="primary" onClick={requestCR3}>
                Download CR-3 PDF
              </Button>
            ) : (
              <div></div>
            )}
          </Col>
        </Row>
      </CardHeader>
      <CardBody className="py-0">
        {cr3FileMetadata?.diagram_s3_file ? (
          <TransformWrapper
            defaultScale={1}
            options={{
              limitToBounds: true,
              limitToWrapper: true,
              centerContent: true,
              minScale: 0.5,
            }}
          >
            {({ zoomIn, zoomOut, resetTransform, ...rest }) => (
              <>
                <Row className="my-2">
                  <Col>
                    <ButtonGroup>
                      <Button color="primary" onClick={zoomIn}>
                        <i className="fa fa-search-plus"></i>
                      </Button>
                      <Button color="primary" onClick={zoomOut}>
                        <i className="fa fa-search-minus"></i>
                      </Button>
                    </ButtonGroup>
                  </Col>
                  <Col className="d-flex justify-content-end">
                    <Button
                      id="reset-zoom-button"
                      color="primary"
                      onClick={resetTransform}
                    >
                      <i className="fa fa-repeat"></i>
                    </Button>
                    <UncontrolledTooltip
                      placement="top"
                      target="reset-zoom-button"
                    >
                      Reset Zoom
                    </UncontrolledTooltip>
                  </Col>
                </Row>
                <Row className="d-flex align-items-center">
                  <Col className="d-flex justify-content-center">
                    <TransformComponent>
                      <img
                        style={{
                          maxHeight: "60vh",
                          maxWidth: "100%",
                          transform: `rotate(${rotation}deg)`,
                        }}
                        src={`https://atd-vision-zero-website.s3.amazonaws.com/cr3_crash_diagrams/${s3Folder}/${cr3FileMetadata.diagram_s3_file}`}
                        alt="crash diagram"
                      />
                    </TransformComponent>
                  </Col>
                </Row>
              </>
            )}
          </TransformWrapper>
        ) : (
          // ) : props.isTempRecord ? (
          //   <div className="mt-2">
          //     CR-3 PDFs, diagrams and narratives are not available for temporary
          //     records. Using the case id, check the{" "}
          //     <a
          //       href={"https://cris.dot.state.tx.us/"}
          //       target={"_blank"}
          //       rel="noopener noreferrer"
          //     >
          //       CRIS website
          //     </a>{" "}
          //     for the latest status of this crash.
          //   </div>
          <div className="mt-2">
            The crash diagram and investigator narrative are not available at
            this time.
          </div>
        )}
      </CardBody>
      {!!cr3FileMetadata && cr3FileMetadata.diagram_s3_file ? (
        <CardFooter className="py-0">
          <form>
            <Row className="form-group d-flex align-items-center mb-0">
              <Col md="3" className="d-flex justify-content-center mt-1">
                <label htmlFor="formControlRange">Rotate Image:</label>
              </Col>
              <Col md="6" className="d-flex justify-content-center mt-1">
                <input
                  type="range"
                  min="-180"
                  max="180"
                  value={rotation}
                  className="form-control-range"
                  id="formControlRange"
                  onChange={rotate}
                ></input>
              </Col>
              <Col md="3" className="d-flex justify-content-center my-1">
                <Button color="primary" onClick={resetRotate}>
                  Reset
                </Button>
              </Col>
            </Row>
          </form>
        </CardFooter>
      ) : (
        <div></div>
      )}
    </Card>
  );
};

export default CrashDiagram;
