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

const CR3_DIAGRAM_BASE_URL = process.env.REACT_APP_CR3_DIAGRAM_BASE_URL;

const CrashDiagram = ({ crashId, isCr3Stored, isTempRecord }) => {
  const [diagramError, setDiagramError] = useState(false);
  const [rotation, setRotation] = useState(0);

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
            <Button
              color="primary"
              onClick={requestCR3}
              disabled={!isCr3Stored}
            >
              Download CR-3 PDF
            </Button>
          </Col>
        </Row>
      </CardHeader>
      {!diagramError && (
        <>
          <CardBody className="py-0">
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
                          src={`${CR3_DIAGRAM_BASE_URL}/${crashId}.jpeg`}
                          alt="crash diagram"
                          onError={() => {
                            console.error("Error loading CR3 diagram image");
                            setDiagramError(true);
                          }}
                        />
                      </TransformComponent>
                    </Col>
                  </Row>
                </>
              )}
            </TransformWrapper>
          </CardBody>
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
        </>
      )}
      {diagramError && (
        <CardBody>
          <p>
            The crash diagram is not available. Typically, this indicates there
            was an error when processing this crash's CR3 PDF.
          </p>
          <p>
            For additional assistance, you can
            <a
              href="https://atd.knack.com/dts#new-service-request/?view_249_vars=%7B%22field_398%22%3A%22Bug%20Report%20%E2%80%94%20Something%20is%20not%20working%22%2C%22field_399%22%3A%22Vision%20Zero%20(Editor)%22%7D"
              target="_blank"
              rel="noopener noreferrer"
            >
              &nbsp;report a bug&nbsp;&nbsp; <i class="fa fa-external-link"></i>
            </a>
            .
          </p>
        </CardBody>
      )}
    </Card>
  );
};

export default CrashDiagram;
