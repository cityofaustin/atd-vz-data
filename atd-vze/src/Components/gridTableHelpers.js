import React from "react";
import get from "lodash.get";
import { Alert } from "reactstrap";

export const renderAlert = alert => <Alert color="warning">{alert}</Alert>;

export const getChartData = (chartData, config) => {
  // Look for records that match labels and increment total
  const data = config.labels.map(label => {
    let labelTotal = 0;
    chartData[config.table].forEach(record => {
      // If record is a string, increment total if match
      if (config.isSingleRecord) {
        if (config.nestedPath) {
          record?.[config.keyName]?.[config.nestedPath] === label &&
            labelTotal++;
        } else {
          record?.[config.keyName] === label && labelTotal++;
        }
      } else {
        // If record is an array of objects, iterate and increment total if match
        record[config.keyName].forEach(unit => {
          get(unit, config.nestedPath) === label && labelTotal++;
        });
      }
    });
    return labelTotal;
  });
  return data;
};

export const getTopValues = (data, config) => {
  // Sort data (descending) and slice to return top n records
  let valueAndLabelArray = [];
  data.forEach((record, i) => {
    valueAndLabelArray.push([record, config.labels[i]]);
  });
  return valueAndLabelArray.sort((a, b) => b[0] - a[0]).slice(0, config.limit);
};
