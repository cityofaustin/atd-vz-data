import React, { useMemo, useState } from "react";
import { Card, CardBody, CardHeader, Table } from "reactstrap";
import { formatDateTimeString } from "../../helpers/format";
import ChangeDetailsModal from "./CrashChangeLogDetails";

const KEYS_TO_IGNORE = ["updated_at", "updated_by", "position"];

/**
 * Return an array of values that are different between the `old` object and `new` object
 * Each object in the array takes the format
 * { field: <property name>, old: <old value>, new: <new value> }
 */
const getDiffArray = (old, new_) => {
  const diffArray = Object.keys(new_).reduce((diffs, key) => {
    if (new_?.[key] !== old?.[key] && KEYS_TO_IGNORE.indexOf(key) < 0) {
      diffs.push({ field: key, old: old?.[key], new: new_?.[key] });
    }
    return diffs;
  }, []);
  // sort array of entries by field name
  diffArray.sort((a, b) => {
    if (a.field < b.field) {
      return -1;
    }
    if (a.field > b.field) {
      return 1;
    }
    return 0;
  });
  return diffArray;
};

/**
 * Prettify the user name if it is `cris`
 */
const formatUserName = userName =>
  userName === "cris" ? "TxDOT CRIS" : userName;

/**
 * Hook that returns an array with one entry per row in the
 * the change log view for the given crash. It adds two properties to the data
 * returned from the change log view:
 * - diffs: an array of old/new values for each field that has changed
 * - affected_fields: an array of the field names that have changed
 */
const useChangeLogData = data =>
  useMemo(() => {
    if (!data) {
      return [];
    }
    return data.map(change => {
      change.diffs = getDiffArray(
        change.record_json.old,
        change.record_json.new
      );
      change.affected_fields = change.diffs.map(diff => diff.field);
      change.created_by = formatUserName(change.created_by);
      return change;
    });
  }, [data]);

const isNewRecordEvent = change => change.operation_type === "create";

/**
 * The primary UI component which renders the change log with clickable rows
 */
export default function CrashChangeLog({ data }) {
  const [selectedChange, setSelectedChange] = useState(null);

  const changes = useChangeLogData(data);
  if (changes.length === 0) {
    return <p>No change history found</p>;
  }

  return (
    <Card>
      <CardHeader>Record history</CardHeader>
      <CardBody>
        <Table responsive striped hover>
          <thead>
            <tr>
              <th>Record type</th>
              <th>Event</th>
              <th>Affected fields</th>
              <th>Edited by</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody className="text-monospace">
            {changes.map(change => (
              <tr
                key={change.id}
                onClick={() => setSelectedChange(change)}
                style={{ cursor: "pointer" }}
              >
                <td>{change.record_type}</td>
                <td>{change.operation_type}</td>
                <td>
                  {isNewRecordEvent(change)
                    ? ""
                    : change.affected_fields.join(", ")}
                </td>
                <td>{change.created_by}</td>
                <td>{formatDateTimeString(change.created_at)}</td>
              </tr>
            ))}
          </tbody>
        </Table>
        {/* Modal with change details table */}
        {selectedChange && (
          <ChangeDetailsModal
            selectedChange={selectedChange}
            setSelectedChange={setSelectedChange}
          />
        )}
      </CardBody>
    </Card>
  );
}
