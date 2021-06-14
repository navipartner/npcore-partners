page 6014421 "NPR DE Audit Setup"
{
    Caption = 'DE Audit Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR DE Audit Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Api URL"; Rec."Api URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies URL of the API';

                    trigger OnValidate()
                    begin
                        Clear(Rec."Last Fiskaly Context");
                        Rec.Modify();
                    end;
                }

                field("DSFINVK Api URL"; Rec."DSFINVK Api URL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies URL of the DSFINVK API';
                }

                field(ApiKeyField; ApiKeyField)
                {
                    ApplicationArea = All;
                    Caption = 'Api Key';
                    Importance = Additional;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Api Key field';

                    trigger OnValidate()
                    begin
                        if ApiKeyField = '' then
                            Rec.RemoveApiKey()
                        else
                            Rec.SetApiKey(ApiKeyField);
                        Clear(Rec."Last Fiskaly Context");
                        Commit();
                    end;
                }
                field(ApiSecretField; ApiSecretField)
                {
                    ApplicationArea = All;
                    Caption = 'Api Secret';
                    Importance = Additional;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Api Secret field';

                    trigger OnValidate()
                    begin
                        if ApiSecretField = '' then
                            Rec.RemoveApiSecret()
                        else
                            Rec.SetApiSecret(ApiSecretField);
                        Clear(Rec."Last Fiskaly Context");
                        Commit();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(PosUnitAuditInfo)
            {
                Caption = 'POS Unit Audit Info';
                Image = SetupLines;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                RunObject = page "NPR DE POS Unit Aux. Info List";
                ToolTip = 'Sets additional information for POS Unit based od DE Fiskaly.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        ApiKeyField := '';
        ApiSecretField := '';

        if Rec.HasApiKey() then
            ApiKeyField := '***';
        if Rec.HasApiSecret() then
            ApiSecretField := '***';
    end;

    var
        ApiKeyField: Text;
        ApiSecretField: Text;
}