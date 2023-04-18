import React, { useState, useEffect } from "react";
import { Link, Redirect, useParams } from "react-router-dom";
import axios from "axios";
import { format, parseISO } from "date-fns";
import {
  Button,
  Card,
  CardBody,
  CardHeader,
  Col,
  Row,
  Table,
  Spinner,
} from "reactstrap";
import Can from "../../auth/Can";
import { useAuth0 } from "../../auth/authContext";
import { rules } from "../../auth/rbac-rules";

const User = () => {
  const token = window.localStorage.getItem("id_token");
  const { id } = useParams();
  const { getRoles } = useAuth0();
  const roles = getRoles();

  // Define attributes to render in view and their labels and format for handling
  const userAttributes = {
    user_id: { label: "User ID", format: "string" },
    name: { label: "Name", format: "string" },
    email: { label: "Email", format: "string" },
    app_metadata: { label: "Roles", format: "roleObject", nestedKey: "roles" },
    created_at: { label: "Created", format: "time" },
    blocked: { label: "Blocked", format: "bool" },
    last_login: { label: "Last login", format: "time" },
    updated_at: { label: "Update at", format: "time" },
    logins_count: { label: "Logins count", format: "string" },
    last_ip: { label: "Last IP", format: "string" },
  };

  const [user, setUser] = useState(null);
  const [isUserDeleted, setIsUserDeleted] = useState(false);
  const [isUserBlocked, setIsUserBlocked] = useState(false);

  useEffect(() => {
    const endpoint = `${process.env.REACT_APP_CR3_API_DOMAIN}/user/get_user/${id}`;
    axios
      .get(endpoint, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      .then(res => {
        // If user not found, redirect to users list
        if (res.data.statusCode === 404) {
          setIsUserDeleted(true);
        } else {
          setUser(res.data);
          if (!!res.data.blocked) {
            setIsUserBlocked(true);
          }
        }
      });
  }, [token, id]);

  // Handle formats of data defined in userAttributes
  const formatUserData = user =>
    Object.entries(userAttributes).map(([key, value]) => {
      const label = userAttributes[key].label;
      let formattedValue = null;

      const attributeFormat = userAttributes[key].format;

      switch (attributeFormat) {
        case "string":
          formattedValue = user[key];
          break;
        case "bool":
          formattedValue = !!user[key] ? "Yes" : "No";
          break;
        case "time":
          formattedValue = !!user[key]
            ? format(parseISO(user[key]), "MM/dd/yyyy, h:mm:ss a")
            : "Never";
          break;
        case "roleObject":
          const nestedKey = value.nestedKey;
          const roleArray = user[key][nestedKey];
          const readableRoleArray = roleArray.map(role => rules[role].label);
          formattedValue = readableRoleArray.join(", ");
          break;
        default:
          console.log("No User view field format match");
      }

      return (
        <tr key={key}>
          <td>{`${label}:`}</td>
          <td>
            <strong>{formattedValue}</strong>
          </td>
        </tr>
      );
    });

  const handleDeleteUserClick = () => {
    const endpoint = `${process.env.REACT_APP_CR3_API_DOMAIN}/user/delete_user/${id}`;
    window.confirm("Are you sure that you want to delete this user?") &&
      axios
        .delete(endpoint, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        })
        .then(() => {
          setIsUserDeleted(true);
        });
  };

  const handleUnblockUserClick = () => {
    const endpoint = `${process.env.REACT_APP_CR3_API_DOMAIN}/user/unblock_user/${id}`;
    axios
      .delete(endpoint, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      .then(() => {
        setIsUserBlocked(false);
      });
  };

  return isUserDeleted ? (
    <Redirect to="/users" />
  ) : (
    <Can
      roles={roles}
      perform="user:get"
      yes={() => (
        <div className="animated fadeIn">
          <Row>
            <Col xs="12" lg="8" xl="6">
              <Card>
                <CardHeader>
                  <strong>
                    <i className="icon-info pr-1"></i>User ID: {id}
                  </strong>
                </CardHeader>
                <CardBody>
                  <Row className="align-items-center mb-3">
                    <Col col="12" xl className="mb-xl-0">
                      <Can
                        roles={roles}
                        perform="user:edit"
                        yes={() => (
                          <Link to={`/users/${id}/edit`} className="link">
                            <Button color="primary" className="mr-2">
                              <i className="fa fa-edit"></i> Edit User
                            </Button>
                          </Link>
                        )}
                      />
                      <Can
                        roles={roles}
                        perform="user:delete"
                        yes={() => (
                          <Button
                            color="danger"
                            onClick={handleDeleteUserClick}
                            className="mr-2"
                          >
                            <i className="fa fa-user-times"></i> Delete User
                          </Button>
                        )}
                      />
                      <Can
                        roles={roles}
                        perform="user:delete"
                        yes={() =>
                          isUserBlocked && (
                            <Button
                              color="warning"
                              onClick={handleUnblockUserClick}
                            >
                              <i className="fa fa-key"></i> Unblock User
                            </Button>
                          )
                        }
                      />
                    </Col>
                  </Row>
                  {!!user ? (
                    <Table responsive striped hover>
                      <tbody>{formatUserData(user)}</tbody>
                    </Table>
                  ) : (
                    <Spinner className="mt-2" color="primary" />
                  )}
                </CardBody>
              </Card>
            </Col>
          </Row>
        </div>
      )}
    />
  );
};

export default User;
