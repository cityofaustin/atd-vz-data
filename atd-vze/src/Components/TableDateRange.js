import React, { useState, useEffect } from "react";
import { withApollo } from "react-apollo";
import styled from "styled-components";
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import { colors } from "../styles/colors";

const StyledDatePicker = styled.div`
  /* Add Bootstrap styles to picker inputs */
  .react-datepicker__input-container > input {
    height: calc(1.5em + 0.75rem + 2px);
    padding: 0.375rem 0.75rem;
    font-size: 0.875rem;
    font-weight: 400;
    line-height: 1.5;
    color: #5c6873;
    background-color: #fff;
    background-clip: padding-box;
    border: 1px solid #e4e7ea;
    border-radius: 0.25rem;
  }

  .react-datepicker__day--selecting-range-start {
    background-color: ${colors.primary} !important;
  }

  .react-datepicker__day--selecting-range-end {
    background-color: ${colors.primary} !important;
  }

  .react-datepicker__day--selected {
    background-color: ${colors.primary} !important;
  }

  .react-datepicker__day--in-selecting-range {
    background-color: ${colors.light};
    color: ${colors.dark};
  }

  .react-datepicker__day.react-datepicker__day--in-range {
    background-color: ${colors.secondary};
  }

  .react-datepicker__header {
    background-color: ${colors.light};
  }
`;

const TableDateRange = ({ setDateRangeFilter, databaseDateColumnName }) => {
  const minDate = new Date("2010/01/01"); // TODO add programatic way to insert earliest crash record in DB
  const maxDate = new Date();
  const [startDate, setStartDate] = useState(minDate);
  const [endDate, setEndDate] = useState(maxDate);

  useEffect(() => {
    const searchQuery = () => {
      let queryStringArray = [];
      queryStringArray.push({
        SEARCH: `where: { ${databaseDateColumnName}: { _gte: "${startDate}", _lte: "${endDate}" } }`,
      });
      queryStringArray.push({ type: `Search` });
      return queryStringArray;
    };
    const queryStringArray = searchQuery();
    setDateRangeFilter(queryStringArray);
  }, [startDate, endDate, setDateRangeFilter]);

  return (
    <>
      <StyledDatePicker>
        <DatePicker
          selected={startDate}
          onChange={date => setStartDate(date)}
          selectsStart
          minDate={minDate}
          startDate={startDate}
          endDate={endDate}
        />
        <span>{" to "}</span>
        <DatePicker
          selected={endDate}
          onChange={date => setEndDate(date)}
          selectsEnd
          startDate={startDate}
          endDate={endDate}
          minDate={startDate}
          maxDate={maxDate}
        />
      </StyledDatePicker>
    </>
  );
};

export default withApollo(TableDateRange);
