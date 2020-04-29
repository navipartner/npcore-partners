page 6059896 "Data Log Subscribers"
{
    // DL1.01/MH/20140820  NP-AddOn: Data Log
    //   - This Form contains information of Data Log consumers. Update of Subscribers is not mandatory and should be maintained manually.
    //     Direct Data Processing defines whether the Data Processing Codeunit should be executed on Runtime.
    // DL1.07/MH/20150515  CASE 214248 Added field "Last Date Modified"
    // DL1.10/MHA/20160412 CASE 239117 Added field 3 Company Name to Primary Key

    Caption = 'Data Log Subscribers';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Data Log Subscriber";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field("Table ID";"Table ID")
                {
                }
                field("Table Name";"Table Name")
                {
                }
                field("Company Name";"Company Name")
                {
                    Visible = false;
                }
                field("Last Log Entry No.";"Last Log Entry No.")
                {
                }
                field("Direct Data Processing";"Direct Data Processing")
                {
                }
                field("Data Processing Codeunit ID";"Data Processing Codeunit ID")
                {
                }
                field("Data Processing Codeunit Name";"Data Processing Codeunit Name")
                {
                }
                field("Last Date Modified";"Last Date Modified")
                {
                }
            }
        }
    }

    actions
    {
    }
}

