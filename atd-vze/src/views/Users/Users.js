import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom";
import axios from "axios";
import { format, parseISO } from "date-fns";
import {
  Badge,
  Card,
  CardBody,
  CardHeader,
  Col,
  Pagination,
  PaginationItem,
  PaginationLink,
  Row,
  Table,
  Button,
  Spinner,
} from "reactstrap";
import Can from "../../auth/Can";
import { useAuth0 } from "../../auth/authContext";
import { rules } from "../../auth/rbac-rules";

const UserRow = ({ user }) => {
  const userLink = `/users/${user.user_id}`;

  const isBlocked = status => status === false || status === undefined;

  const getBadge = status => {
    return isBlocked(status) ? "success" : "danger";
  };

  const getStatus = status => {
    return isBlocked(status) ? "Active" : "Blocked";
  };

  return (
    <tr key={user.user_id.toString()}>
      <th scope="row">
        <Link to={userLink}>{user.name}</Link>
      </th>
      <td>
        <Link to={userLink}>{user.email}</Link>
      </td>
      <td>{format(parseISO(user.created_at), "MM/dd/yyyy")}</td>
      <td>{user.logins_count}</td>
      <td>
        {user.last_login
          ? format(parseISO(user.last_login), "MM/dd/yyyy")
          : "Never"}
      </td>
      <td>{rules[user.app_metadata.roles[0]].label}</td>
      <td>
        <Link to={userLink}>
          <Badge color={getBadge(user.blocked)}>
            {getStatus(user.blocked)}
          </Badge>
        </Link>
      </td>
    </tr>
  );
};

const Users = () => {
  const { getRoles } = useAuth0();
  const token = window.localStorage.getItem("id_token");

  const [userList, setUserList] = useState(null);
  const [totalUsers, setTotalUsers] = useState(null);
  const [page, setPage] = useState(0);
  const perPage = 50;

  useEffect(() => {
    const endpoint = `${process.env.REACT_APP_CR3_API_DOMAIN}/user/list_users?page=${page}&per_page=${perPage}`;
    axios
      .get(endpoint, {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      .then(res => {
        setUserList(res.data.users);
        setTotalUsers(res.data.total);
      });
  }, [token, page, perPage]);

  const pageCount = Math.ceil(totalUsers / perPage);

  const updatePage = newPageValue => {
    setUserList(null);
    setPage(newPageValue);
  };

  return (
    <Can
      roles={getRoles()}
      perform="users:get"
      yes={() => (
        <div className="animated fadeIn">
          <Row>
            <Col>
              <Card>
                <CardHeader>
                  <i className="fa fa-align-justify"></i> Users
                </CardHeader>
                <CardBody>
                  <Row className="align-items-center">
                    <Col
                      xs="12"
                      md="6"
                      className="d-flex justify-content-md-start justify-content-center ml-0 mb-3"
                    >
                      <Link to="/users/add" className="link">
                        <Button color="primary">
                          <i className="fa fa-user-plus"></i> Add User
                        </Button>
                      </Link>
                    </Col>
                    <Col
                      xs="12"
                      md="6"
                      className="d-flex justify-content-md-end justify-content-center mr-0"
                    >
                      <Pagination>
                        <PaginationItem disabled={page <= 0}>
                          <PaginationLink first onClick={() => updatePage(0)} />
                        </PaginationItem>
                        <PaginationItem disabled={page <= 0}>
                          <PaginationLink
                            previous
                            onClick={() => updatePage(page - 1)}
                          />
                        </PaginationItem>
                        <PaginationItem disabled>
                          <PaginationLink>
                            Page {page + 1}/{pageCount}
                          </PaginationLink>
                        </PaginationItem>
                        <PaginationItem disabled>
                          <PaginationLink>Users: {totalUsers}</PaginationLink>
                        </PaginationItem>
                        <PaginationItem disabled={page >= pageCount - 1}>
                          <PaginationLink
                            next
                            onClick={() => updatePage(page + 1)}
                          />
                        </PaginationItem>
                        <PaginationItem disabled={page >= pageCount - 1}>
                          <PaginationLink
                            last
                            onClick={() => updatePage(pageCount - 1)}
                          />
                        </PaginationItem>
                      </Pagination>
                    </Col>
                  </Row>
                  {!!userList ? (
                    <Table responsive striped hover>
                      <thead>
                        <tr>
                          <th scope="col">Name</th>
                          <th scope="col">Email</th>
                          <th scope="col">Created</th>
                          <th scope="col">Logins Count</th>
                          <th scope="col">Last Login</th>
                          <th scope="col">Role</th>
                          <th scope="col">Status</th>
                        </tr>
                      </thead>
                      <tbody>
                        {userList.map((user, index) => (
                          <UserRow key={index} user={user} />
                        ))}
                      </tbody>
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

export default Users;
