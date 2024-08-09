import React, { useState, useEffect } from "react";
import axios from "axios";
import SummaryWidget from "../../Components/Widgets/SummaryWidget";
import InfoPopover from "../../Components/Popover/InfoPopover";
import { popoverConfig } from "../../Components/Popover/popoverConfig";
import { Row, Col } from "reactstrap";

import {
  summaryCurrentYearStartDate,
  summaryCurrentYearEndDate,
  summaryLastYearStartDate,
  summaryLastYearEndDate,
  currentYearString as currentYear,
  prevYearString as prevYear,
} from "../../constants/time";
import { personEndpointUrl, crashEndpointUrl } from "./queries/socrataQueries";
import {
  calcSummaryTotalFatalities,
  getSummaryYearsOfLifeLost,
  calcSummaryTotalSeriousInjuries,
  calcSummaryTotalCrashes,
} from "./helpers/helpers";
import { colors } from "../../constants/colors";
import {
  faCar,
  faHourglassHalf,
  faHeartbeat,
  faMedkit,
} from "@fortawesome/free-solid-svg-icons";

const SummaryView = () => {
  const [fatalities, setFatalities] = useState(null);
  const [yearsOfLifeLost, setYearsOfLifeLost] = useState(null);
  const [seriousInjuries, setSeriousInjuries] = useState(null);
  const [totalCrashes, setTotalCrashes] = useState(null);

  useEffect(() => {
    const fatalitiesUrl = `${crashEndpointUrl}?$where=(death_cnt > 0 AND crash_timestamp_ct between '${summaryCurrentYearStartDate}T00:00:00' and '${summaryCurrentYearEndDate}T23:59:59') OR (death_cnt > 0 AND crash_timestamp_ct between '${summaryLastYearStartDate}T00:00:00' and '${summaryLastYearEndDate}T23:59:59')`;
    const yearsOfLifeLostUrl = `${personEndpointUrl}?$where=(prsn_injry_sev_id = '4' AND crash_timestamp_ct between '${summaryCurrentYearStartDate}T00:00:00' and '${summaryCurrentYearEndDate}T23:59:59') OR (prsn_injry_sev_id = '4' AND crash_timestamp_ct between '${summaryLastYearStartDate}T00:00:00' and '${summaryLastYearEndDate}T23:59:59')`;
    const seriousInjuriesUrl = `${crashEndpointUrl}?$where=(sus_serious_injry_cnt > 0 AND crash_timestamp_ct between '${summaryCurrentYearStartDate}T00:00:00' and '${summaryCurrentYearEndDate}T23:59:59') OR (sus_serious_injry_cnt > 0 AND crash_timestamp_ct between '${summaryLastYearStartDate}T00:00:00' and '${summaryLastYearEndDate}T23:59:59')`;
    const totalCrashesUrl = `${crashEndpointUrl}?$limit=100000&$where=(crash_timestamp_ct between '${summaryCurrentYearStartDate}T00:00:00' and '${summaryCurrentYearEndDate}T23:59:59') OR (crash_timestamp_ct between '${summaryLastYearStartDate}T00:00:00' and '${summaryLastYearEndDate}T23:59:59')`;

    const requestConfigs = [
      {
        url: fatalitiesUrl,
        handler: calcSummaryTotalFatalities,
        setter: setFatalities,
      },
      {
        url: yearsOfLifeLostUrl,
        handler: getSummaryYearsOfLifeLost,
        setter: setYearsOfLifeLost,
      },
      {
        url: seriousInjuriesUrl,
        handler: calcSummaryTotalSeriousInjuries,
        setter: setSeriousInjuries,
      },
      {
        url: totalCrashesUrl,
        handler: calcSummaryTotalCrashes,
        setter: setTotalCrashes,
      },
    ];

    requestConfigs.forEach((config) => {
      const { url, setter, handler } = config;
      axios
        .get(url)
        .then((res) => setter(handler(res.data, prevYear, currentYear)));
    });
  }, []);

  const summaryWidgetsConfig = [
    {
      title: `Fatalities`,
      totalsObject: fatalities,
      icon: faHeartbeat,
      color: colors.fatalities,
    },
    {
      title: `Years of Life Lost`,
      infoPopover: (
        <InfoPopover config={popoverConfig.summary.yearsOfLifeLost} />
      ),
      totalsObject: yearsOfLifeLost,
      icon: faHourglassHalf,
      color: colors.yearsOfLifeLost,
    },
    {
      title: `Serious Injuries`,
      totalsObject: seriousInjuries,
      icon: faMedkit,
      color: colors.seriousInjuries,
    },
    {
      title: `Total Crashes`,
      totalsObject: totalCrashes,
      icon: faCar,
      color: colors.totalCrashes,
    },
  ];

  return (
    <Row>
      {summaryWidgetsConfig.map((config, i) => (
        // Set Bootstrap breakpoints to divide into two rows on large mobile devices and below
        <Col className="summary-child" key={i} xs="12" sm="6" xl="3">
          <SummaryWidget
            text={config.title}
            totalsObject={config.totalsObject}
            icon={config.icon}
            backgroundColor={config.color}
            infoPopover={config.infoPopover}
          />
        </Col>
      ))}
    </Row>
  );
};

export default SummaryView;
