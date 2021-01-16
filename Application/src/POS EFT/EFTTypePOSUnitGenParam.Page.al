page 6184479 "NPR EFTType POSUnit Gen.Param."
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Type POS Unit Gen. Param.';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR EFTType POSUnit Gen.Param.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ParameterName; ParameterName)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(ParameterDescription; ParameterDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Data Type"; "Data Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field(ParameterValue; ParameterValue)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    Editable = "User Configurable";
                    ToolTip = 'Specifies the value of the Value field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        LookupValue();
                        Modify;
                        SetParameterValue();
                    end;

                    trigger OnValidate()
                    begin
                        Validate(Value, ParameterValue);
                        Modify;
                        SetParameterValue();
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetParameterName();
        SetParameterDescription();
        SetParameterValue();
    end;

    var
        ParameterName: Text;
        ParameterDescription: Text;
        ParameterValue: Text;

    local procedure SetParameterName()
    begin
        Clear(ParameterName);
        OnGetParameterNameCaption(Rec, ParameterName);
        if (ParameterName = '') then
            ParameterName := Name;
    end;

    local procedure SetParameterDescription()
    begin
        Clear(ParameterDescription);
        OnGetParameterDescriptionCaption(Rec, ParameterDescription);
    end;

    local procedure SetParameterValue()
    var
        ParameterOptionString: Text;
    begin
        Clear(ParameterOptionString);
        Clear(ParameterValue);
        OnGetParameterOptionStringCaption(Rec, ParameterOptionString);
        if ParameterOptionString = '' then
            ParameterOptionString := OptionString;
        if (ParameterOptionString = '') or ("Data Type" <> "Data Type"::Option) then
            ParameterValue := Value
        else
            ParameterValue := GetOptionStringCaption(ParameterOptionString)
    end;

    local procedure GetOptionStringCaption(ParameterOptionStringCaption: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
        OptionCaption: Text;
        Option: Integer;
    begin
        Evaluate(Option, Rec.Value);
        if TrySelectStr(Option, ParameterOptionStringCaption, OptionCaption) then
            exit(OptionCaption)
        else
            exit(Value);
    end;

    [TryFunction]
    local procedure TrySelectStr(Ordinal: Integer; OptionString: Text; var OptionOut: Text)
    begin
        OptionOut := SelectStr(Ordinal + 1, OptionString);
    end;
}

