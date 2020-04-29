page 6150622 "POS Payment Bin Eject Params"
{
    // NPR5.40/MMV /20180326 CASE 300660 Created object
    // NPR5.41/MMV /20180425 CASE 312990 Renamed object.

    Caption = 'POS Payment Bin Eject Parameters';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "POS Payment Bin Eject Param.";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ParameterName;ParameterName)
                {
                    Caption = 'Name';
                    Editable = false;
                }
                field(ParameterDescription;ParameterDescription)
                {
                    Caption = 'Description';
                    Editable = false;
                }
                field("Data Type";"Data Type")
                {
                    Editable = false;
                }
                field(ParameterValue;ParameterValue)
                {
                    Caption = 'Value';

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
        if ParameterName = '' then
          ParameterName := Name;
    end;

    local procedure SetParameterDescription()
    begin
        Clear(ParameterDescription);
        OnGetParameterDescriptionCaption(Rec, ParameterDescription);
    end;

    local procedure SetParameterValue()
    var
        OptionStringCaption: Text;
        OptionCaption: Text;
        Ordinal: Integer;
    begin
        Clear(ParameterValue);
        if "Data Type" <> "Data Type"::Option then begin
          ParameterValue := Value;
          exit;
        end;

        Evaluate(Ordinal, Value);

        OnGetParameterOptionStringCaption(Rec, OptionStringCaption);
        if (OptionStringCaption <> '') then
          TrySelectStr(Ordinal, OptionStringCaption, OptionCaption)
        else
          TrySelectStr(Ordinal, OptionString, OptionCaption);

        ParameterValue := OptionCaption;
    end;
}

