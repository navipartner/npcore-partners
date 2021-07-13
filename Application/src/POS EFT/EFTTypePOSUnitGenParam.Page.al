page 6184479 "NPR EFTType POSUnit Gen.Param."
{
    Caption = 'EFT Type POS Unit Gen. Param.';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
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

                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(ParameterDescription; ParameterDescription)
                {

                    Caption = 'Description';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Data Type"; Rec."Data Type")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Data Type field';
                    ApplicationArea = NPRRetail;
                }
                field(ParameterValue; ParameterValue)
                {

                    Caption = 'Value';
                    Editable = Rec."User Configurable";
                    ToolTip = 'Specifies the value of the Value field';
                    ApplicationArea = NPRRetail;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.LookupValue();
                        Rec.Modify();
                        SetParameterValue();
                    end;

                    trigger OnValidate()
                    begin
                        Rec.Validate(Value, ParameterValue);
                        Rec.Modify();
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
        Rec.OnGetParameterNameCaption(Rec, ParameterName);
        if (ParameterName = '') then
            ParameterName := Rec.Name;
    end;

    local procedure SetParameterDescription()
    begin
        Clear(ParameterDescription);
        Rec.OnGetParameterDescriptionCaption(Rec, ParameterDescription);
    end;

    local procedure SetParameterValue()
    var
        ParameterOptionString: Text;
    begin
        Clear(ParameterOptionString);
        Clear(ParameterValue);
        Rec.OnGetParameterOptionStringCaption(Rec, ParameterOptionString);
        if ParameterOptionString = '' then
            ParameterOptionString := Rec.OptionString;
        if (ParameterOptionString = '') or (Rec."Data Type" <> Rec."Data Type"::Option) then
            ParameterValue := Rec.Value
        else
            ParameterValue := GetOptionStringCaption(ParameterOptionString)
    end;

    local procedure GetOptionStringCaption(ParameterOptionStringCaption: Text): Text
    var
        OptionCaption: Text;
        Option: Integer;
    begin
        Evaluate(Option, Rec.Value);
        if Rec.TrySelectStr(Option, ParameterOptionStringCaption, OptionCaption) then
            exit(OptionCaption)
        else
            exit(Rec.Value);
    end;
}

