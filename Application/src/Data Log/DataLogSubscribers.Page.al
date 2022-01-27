page 6059896 "NPR Data Log Subscribers"
{
    Extensible = False;
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
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Table ID"; Rec."Table ID")
                {

                    ToolTip = 'Specifies the value of the Table ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Log Entry No."; Rec."Last Log Entry No.")
                {

                    ToolTip = 'Specifies the value of the Last Log Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Direct Data Processing"; Rec."Direct Data Processing")
                {

                    ToolTip = 'Specifies the value of the Direct Data Processing field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Processing Codeunit ID"; Rec."Data Processing Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Data Processing Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Processing Codeunit Name"; Rec."Data Processing Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Data Processing Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {

                    ToolTip = 'Specifies the value of the Last Date Modified field';
                    ApplicationArea = NPRRetail;
                }
                field("Delayed Data Processing (sec)"; Rec."Delayed Data Processing (sec)")
                {

                    ToolTip = 'Specifies the number of seconds for Delayed Data Processing';
                    ApplicationArea = NPRRetail;
                }
                field("Failure Codeunit ID"; Rec."Failure Codeunit ID")
                {

                    ToolTip = 'Specifies ID of Failure Codeunit';
                    ApplicationArea = NPRRetail;
                }
                field("Failure Codeunit Caption"; Rec."Failure Codeunit Caption")
                {

                    ToolTip = 'Specifies the Caption of Failure Codeunit';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

