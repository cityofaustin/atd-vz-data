import React from "react";
import { withApollo } from "react-apollo";
import styled from "styled-components";

const StyledArrow = styled.i`
  cursor: pointer;
`;

const GridTableHeader = ({
  query,
  handleTableHeaderClick,
  sortColumn,
  sortOrder,
  helperText,
}) => {
  /**
   * Renders a label with sorting icons going up or down
   * @param {string} col - the name of the column (label)
   * @param {boolean} sortable - true if the column is sortable
   * @param {boolean} ascending - true if ordering in ascending mode
   * @returns {object} jsx component
   */
  const renderLabel = (col, ascending, isSorting) => {
    if (isSorting) {
      // show a sort arrow next to the column that's actively being sorted
      return (
        <StyledArrow>
          <i className={`fa fa-arrow-circle-${ascending ? "up" : "down"}`} />
          &nbsp;{col}
        </StyledArrow>
      );
    } else {
      return col;
    }
  };

  const colspan = query.columns.length;

  return (
    <>
      <thead>
        {helperText && (
          <tr>
            <th colSpan={colspan}>
              <small className="pull-right">{helperText}</small>
            </th>
          </tr>
        )}
        <tr>
          {query.columns.map(
            (column, index) =>
              // If column is hidden, don't render <th>
              !query.isHidden(column) && (
                <th
                  onClick={
                    query.isSortable(column)
                      ? e => handleTableHeaderClick(column)
                      : null
                  }
                  key={`th-${index}`}
                  style={{cursor: "pointer"}}
                >
                  {renderLabel(
                    // Get a human-readable label string
                    query.getLabel(column, "table"),
                    // If sort column is defined, use sort order, or false as default
                    sortColumn === column ? sortOrder === "asc" : false,
                    sortColumn === column
                  )}
                </th>
              )
          )}
        </tr>
      </thead>
    </>
  );
};

export default withApollo(GridTableHeader);
