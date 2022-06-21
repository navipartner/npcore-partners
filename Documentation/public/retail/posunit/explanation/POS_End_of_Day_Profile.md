# POS End of Day Profile

In POS End of Day profile it is defined how and how often End of Day will be done. To define it, next fields should be setup:

- **Code** - Unique code for profile.
- **Description** - Short description for profile.
- **End of Day Frequency** - **Daily** (End of Day will be done every day) or **Never** (End of Day will not be done)
- **End of Day Type** - **Master&Slave** (there is master and slave POS units, master unit is unit in which balancing is done for slave pos units) or **Individual** (every pos unit has to be balanced individualy)
- **Master POS unit No.** - POS unit in which will be done balancing if End of Day Type is Master&Slave.
- **Z-report UI** - **Summary+Balancing** – when running z-report first will be open page with summary and then balancing page  or **Only Balancing** – balancing page is opened immediately.
- **X-Report UI** - **Summary+Balancing** when running z-report first will be open page with summary and then balancing page  or **Only Balancing** – balancing page is opened immediately.
- **Close Workshift UI** – **Print** or **No print**
- **Force Blind Counting** – If this field is checked in balancing page it will not be shown amount in system.
- **SMS profile** - SMS template which will be used for sending SMS after balancing is done.
- **Z-Report Number Series** – Number series used for creatin Document No. in POS entry for entries created from running Z report.
- **X-Report Number series** - Number series used for creatin Document No. in POS entry for entries created from running X report.
- **Show Zero Amount Lines** - In balancing page will be shown all payment methods even if they haven’t been used.
- **Hide Turnover Section** - If this field is checked, in page for summery turnover section will be hidden.

![endofday](../images/End%20of%20day%20profile.PNG)