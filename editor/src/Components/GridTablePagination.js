import React, { useState } from "react";
import {
  ButtonToolbar,
  Button,
  ButtonGroup,
  ButtonDropdown,
  DropdownMenu,
  DropdownToggle,
  DropdownItem,
} from "reactstrap";
import { withApollo } from "react-apollo";
import styled from "styled-components";

const StyledDisableClick = styled.i`
  pointer-events: none;
`;

const rowsPerPage = [10, 25, 50, 100, 250, 500];

const GridTablePagination = ({
  moveNext,
  moveBack,
  limit,
  pageNumber,
  handleRowClick,
  recordsCount,
}) => {
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);

  /**
   * Toggles our limit dropdown
   */
  const toggleDropdown = () => {
    setIsDropdownOpen(!isDropdownOpen);
  };

  return (
    <>
      <ButtonToolbar className="">
        <ButtonGroup>
          <Button onClick={moveBack} disabled={pageNumber < 2 ? true : false}>
            <StyledDisableClick>
              <i className="fa fa-arrow-circle-left" />
            </StyledDisableClick>{" "}
            Prev
          </Button>
          <StyledDisableClick>
            <Button color="light">Page {pageNumber.toLocaleString()}</Button>
          </StyledDisableClick>

          <Button
            onClick={moveNext}
            // if record count on the current page is less than the limit or zero, disable next page button
            disabled={recordsCount < limit || recordsCount === 0 ? true : false}
          >
            Next{" "}
            <StyledDisableClick>
              <i className="fa fa-arrow-circle-right" />
            </StyledDisableClick>
          </Button>
        </ButtonGroup>
        <ButtonDropdown
          className="ml-2 mr-1"
          isOpen={isDropdownOpen}
          toggle={toggleDropdown}
        >
          <DropdownToggle caret color="secondary">
            Rows per page: <b>{limit}</b>
          </DropdownToggle>
          <DropdownMenu>
            {rowsPerPage.map(rows => (
              <DropdownItem
                onClick={handleRowClick}
                value={rows}
                key={`rows-${rows}`}
                className={rows === limit ? "font-weight-bold" : ""}
              >
                {rows}
              </DropdownItem>
            ))}
          </DropdownMenu>
        </ButtonDropdown>
      </ButtonToolbar>
      <br />
    </>
  );
};

export default withApollo(GridTablePagination);
