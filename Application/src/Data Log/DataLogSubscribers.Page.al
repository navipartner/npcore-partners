page 6059896 "NPR Data Log Subscribers"
{
    // DL1.01/MH/20140820  NP-AddOn: Data Log
    //   - This Form contains information of Data Log consumers. Update of Subscribers is not mandatory and should be maintained manually.
    //     Direct Data Processing defines whether the Data Processing Codeunit should be executed on Runtime.
    // DL1.07/MH/20150515  CASE 214248 Added field "Last Date Modified"
    // DL1.10/MHA/20160412 CASE 239117 Added field 3 Company Name to Primary Key

    Caption = 'Data Log Subscribers';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Data Log Subscriber";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table ID field';
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Last Log Entry No."; "Last Log Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Log Entry No. field';
                }
                field("Direct Data Processing"; "Direct Data Processing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direct Data Processing field';
                }
                field("Data Processing Codeunit ID"; "Data Processing Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Processing Codeunit ID field';
                }
                field("Data Processing Codeunit Name"; "Data Processing Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Processing Codeunit Name field';
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Date Modified field';
                }
            }
        }
    }

    actions
    {
    }
}

