page 6150981 "NPR API BI Allowed Tables"
{
    Caption = 'BI API Allowed Tables';
    PageType = List;
    SourceTable = "NPR API BI Allowed Table";
    ApplicationArea = NPRRetail;
    UsageCategory = Administration;
    AdditionalSearchTerms = 'BI API, Business Intelligence API, tablemetadata, API Key Tables';
    Extensible = false;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(AllowedTablesRepeater)
            {
                field("Principal Type"; Rec."Principal Type")
                {
                    ApplicationArea = NPRRetail;
                }
                field("Principal Id"; Rec."Principal Id")
                {
                    ApplicationArea = NPRRetail;
                }
                field(PrincipalDescription; _PrincipalDescription)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Principal Description';
                    ToolTip = 'Specifies the description of the NaviPartner API Key or Entra ID application that the table is allowed for.';
                    Editable = false;
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = NPRRetail;
                }
                field(TableCaption; _TableCaptionText)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Table Caption';
                    ToolTip = 'Specifies the caption of the table that the principal is allowed to read.';
                    Editable = false;
                }
            }
        }
    }

    var
        _PrincipalDescription: Text;
        _TableCaptionText: Text;

    trigger OnAfterGetRecord()
    begin
        UpdateDisplayFields();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateDisplayFields();
    end;

    // Opened from an API key or from an Entra ID application, the page carries that principal as a
    // filter. New rows then belong to the same principal, so the user does not have to retype it.
    trigger OnNewRecord(BelowxRec: Boolean)
    var
        PrincipalIdFilter: Text;
        PrincipalIdFromFilter: Guid;
    begin
        if Rec.GetFilter("Principal Type") <> '' then
            Rec."Principal Type" := Rec.GetRangeMin("Principal Type");

        PrincipalIdFilter := Rec.GetFilter("Principal Id");
        if PrincipalIdFilter <> '' then
            if Evaluate(PrincipalIdFromFilter, PrincipalIdFilter) then
                Rec."Principal Id" := PrincipalIdFromFilter;
    end;

    local procedure UpdateDisplayFields()
    begin
        _PrincipalDescription := Rec.GetPrincipalDescription();
        _TableCaptionText := Rec.GetTableCaption();
    end;
}
