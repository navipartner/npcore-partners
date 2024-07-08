page 6150826 "NPR SE CC Cash Reg. Audit Log"
{
    ApplicationArea = NPRSECleanCash;
    Caption = 'CleanCash Cash Register Audit Log';
    Editable = false;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR SE CC Cash Reg. Audit Log";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRSECleanCash;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field("Record ID"; FormattedRecordID)
                {
                    ApplicationArea = NPRSECleanCash;
                    Caption = 'Record ID';
                    ToolTip = 'Specifies the value of the Record ID field.';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = NPRSECleanCash;
                    ToolTip = 'Specifies the value of the Table ID field.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = NPRSECleanCash;
                    ToolTip = 'Specifies the value of the Table Name field.';
                }
                field("External Description"; Rec."External Description")
                {
                    ApplicationArea = NPRSECleanCash;
                    ToolTip = 'Specifies the value of the External Description field.';
                }
                field("Additional Information"; Rec."Additional Information")
                {
                    ApplicationArea = NPRSECleanCash;
                    ToolTip = 'Specifies the value of the Additional Information field.';
                }
                field("Log Timestamp"; Rec."Entry Date")
                {
                    ApplicationArea = NPRSECleanCash;
                    ToolTip = 'Specifies the value of the Log Timestamp field.';
                }
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        FormatRecordId();
    end;

    local procedure FormatRecordId()
    begin
        FormattedRecordID := Format(Rec."Record ID");
    end;

    var
        FormattedRecordID: Text;
}