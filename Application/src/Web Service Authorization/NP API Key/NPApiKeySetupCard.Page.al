page 6150969 "NPR NP API Key Setup Card"
{
    Extensible = false;
    Caption = 'API Key Authorization Setup';
    PageType = Card;
    SourceTable = "NPR NP API Key Setup";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec."Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique code identifying this NP API Key setup.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies a description of this NP API Key setup.';
                }
                field(ApiKey; _ApiKeyValue)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'API Key';
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the API Key sent in the x-np-api-key header. Enter a value to set or replace the key, or clear it to remove the key. The key is kept in isolated storage and is never displayed again — the masked hint below identifies the stored key.';
                    trigger OnValidate()
                    begin
                        SetApiKeyFromInput();
                    end;
                }
                field("Key Secret Hint"; Rec."Key Secret Hint")
                {
                    ApplicationArea = NPRRetail;
                    Editable = false;
                    ToolTip = 'Displays a masked preview of the stored API key for identification purposes. The full key is never displayed again.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether this NP API Key setup is enabled and can be used for authorization.';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        SetApiKeyPlaceholder();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        _ApiKeyValue := '';
    end;

    [NonDebuggable]
    local procedure SetApiKeyFromInput()
    begin
        // Browser autofill treats this masked field as a password and can drop a value into it on a
        // brand-new record before a Code is entered. Don't create the record or store a secret (which
        // would SaveRecord a blank-Code row) until the record actually has a Code.
        if Rec.Code = '' then begin
            _ApiKeyValue := '';
            exit;
        end;

        // Ignore the unchanged placeholder (a key is already stored) and the hint value, so a stray edit
        // of the masked field can't overwrite the stored key with a fragment.
        if (_ApiKeyValue = _HasValueTok) or (_ApiKeyValue = Rec."Key Secret Hint") then begin
            SetApiKeyPlaceholder();
            exit;
        end;

        if _ApiKeyValue = '' then
            Rec.RemoveApiKey()
        else
            Rec.SetApiKey(_ApiKeyValue);

        CurrPage.SaveRecord();
        SetApiKeyPlaceholder();
    end;

    local procedure SetApiKeyPlaceholder()
    begin
        // A non-empty masked placeholder marks "a key is stored" without exposing it; empty means no key,
        // so clearing the field is an unambiguous removal.
        if Rec.HasApiKey() then
            _ApiKeyValue := _HasValueTok
        else
            _ApiKeyValue := '';
    end;

    var
        _ApiKeyValue: Text;
        _HasValueTok: Label 'HasValue', Locked = true;
}
