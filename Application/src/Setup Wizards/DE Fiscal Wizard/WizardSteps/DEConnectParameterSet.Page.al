page 6184763 "NPR DE Connect. Parameter Set"
{
    Caption = 'DE Connection Parameter Set';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR DE Audit Setup";
    ObsoleteReason = 'Introduced page NPR DE Conn. Param. Sets Step instead.';
    ObsoleteState = Pending;
    ObsoleteTag = '2025-02-09';
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Primary Key")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code value associated with the Voucher Type';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the description of the Voucher Type';
                }
                field("Fiskaly API URL"; Rec."Api URL")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the code of the No. Series field for the Voucher Type';
                }
                field(ApiKeyField; ApiKeyField)
                {
                    Caption = 'Api Key';
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Api Key field';
                    ApplicationArea = NPRDEFiscal;

                    trigger OnValidate()
                    begin
                        if ApiKeyField = '' then
                            DESecretMgt.RemoveSecretKey(Rec.ApiKeyLbl())
                        else
                            DESecretMgt.SetSecretKey(Rec.ApiKeyLbl(), ApiKeyField);
                    end;
                }
                field(ApiSecretField; ApiSecretField)
                {
                    Caption = 'Api Secret';
                    Importance = Additional;
                    ToolTip = 'Specifies the value of the Api Secret field';
                    ApplicationArea = NPRDEFiscal;

                    trigger OnValidate()
                    begin
                        if ApiSecretField = '' then
                            DESecretMgt.RemoveSecretKey(Rec.ApiSecretLbl())
                        else
                            DESecretMgt.SetSecretKey(Rec.ApiSecretLbl(), ApiSecretField);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        DEAuditSetup: Record "NPR DE Audit Setup";
    begin
        if not Rec.IsEmpty() then
            Rec.DeleteAll();
        if DEAuditSetup.FindSet() then
            repeat
                if not Rec.Get(DEAuditSetup."Primary Key") then begin
                    Rec := DEAuditSetup;
                    Rec.Insert();
                end;
            until DEAuditSetup.Next() = 0;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec."Api URL" = '' then
            Rec."Api URL" := 'https://kassensichv-middleware.fiskaly.com/api/v2';
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ApiKeyField := '';
        ApiSecretField := '';

        if DESecretMgt.HasSecretKey(Rec.ApiKeyLbl()) then
            ApiKeyField := '***';
        if DESecretMgt.HasSecretKey(Rec.ApiSecretLbl()) then
            ApiSecretField := '***';
    end;

    var
        DESecretMgt: Codeunit "NPR DE Secret Mgt.";
        ApiKeyField: Text[200];
        ApiSecretField: Text[200];
}