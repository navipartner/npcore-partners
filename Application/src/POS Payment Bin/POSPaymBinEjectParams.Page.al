page 6150622 "NPR POS Paym. Bin Eject Params"
{
    // NPR5.40/MMV /20180326 CASE 300660 Created object
    // NPR5.41/MMV /20180425 CASE 312990 Renamed object.

    Caption = 'POS Payment Bin Eject Parameters';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Paym. Bin Eject Param.";

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
        if ParameterName = '' then
            ParameterName := Rec.Name;
    end;

    local procedure SetParameterDescription()
    begin
        Clear(ParameterDescription);
        Rec.OnGetParameterDescriptionCaption(Rec, ParameterDescription);
    end;

    local procedure SetParameterValue()
    var
        OptionStringCaption: Text;
        OptionCaption: Text;
        Ordinal: Integer;
    begin
        Clear(ParameterValue);
        if Rec."Data Type" <> Rec."Data Type"::Option then begin
            ParameterValue := Rec.Value;
            exit;
        end;

        Evaluate(Ordinal, Rec.Value);

        Rec.OnGetParameterOptionStringCaption(Rec, OptionStringCaption);
        if (OptionStringCaption <> '') then
            Rec.TrySelectStr(Ordinal, OptionStringCaption, OptionCaption)
        else
            Rec.TrySelectStr(Ordinal, Rec.OptionString, OptionCaption);

        ParameterValue := OptionCaption;
    end;
}

