page 6150974 "NPR Change Quarantine"
{
    ApplicationArea = NPRRetail;
    Caption = 'Change Quarantine';
    PageType = List;
    SourceTable = "NPR Change Quarantine";
    UsageCategory = None;
    Extensible = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the entry number of the quarantined change.';
                }
                field("Integration Type"; Rec."Integration Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the integration whose change detection quarantined this row.';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ID of the table the quarantined row belongs to.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the table the quarantined row belongs to.';
                }
                field("Row Version"; Rec."Row Version")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the SQL row version of the quarantined change.';
                }
                field("Record ID"; Format(Rec."Record ID"))
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Record ID';
                    ToolTip = 'Specifies the Business Central record whose change dispatch kept failing.';
                }
                field("Error Text"; Rec."Error Text")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the error raised on the last dispatch attempt before the row was quarantined.';
                }
                field("Quarantined At"; Rec."Quarantined At")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies when the row was quarantined. The change detection has advanced past it; the entity re-syncs on its next real change or via the re-sync tooling.';
                }
            }
        }
    }
}
