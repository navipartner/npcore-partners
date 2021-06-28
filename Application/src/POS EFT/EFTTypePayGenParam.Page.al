page 6184478 "NPR EFT Type Pay. Gen. Param."
{
    Caption = 'EFT Type Payment Gen. Param.';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = ListPart;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR EFT Type Pay. Gen. Param.";

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
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Data Type"; Rec."Data Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field(ParameterValue; ParameterValue)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    Editable = Rec."User Configurable";
                    ToolTip = 'Specifies the value of the Value field';

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

