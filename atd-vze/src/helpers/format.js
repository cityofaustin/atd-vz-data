import { format, parseISO } from "date-fns";

export const formatCostToDollars = cost =>
  cost || cost === 0 ? `$${cost.toLocaleString()}` : "--";

export const formatDateTimeString = datetime =>
  format(parseISO(datetime), "yyyy-MM-dd h:mm:ss a");
