page 6150705 "NPR POS Parameter Values"
{
    // NPR5.34/BR  /20170703  CASE 282915 Highlight non-default parameters
    // NPR5.40/VB  /20180228  CASE 306347 Replacing BLOB-based temporary-table parameters with physical-table parameters
    // NPR5.40/MMV /20180321  CASE 308050 Added support for parameter caption and parameter description.
    // NPR5.54/ALPO/20200330  CASE 335834 Enable lookup and value translations for parameters of type boolean
    //                                    Functions GetOptionStringCaption() and TrySelectStr() moved to the source table to avoid code dublication

    Caption = 'POS Parameter Values';
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Parameter Value";

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
                    Style = StandardAccent;
                    StyleExpr = ParameterIsNotDefault;
                    ToolTip = 'Specifies the value of the Data Type field';
                }
                field(ParameterValue; ParameterValue)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    Style = StandardAccent;
                    StyleExpr = ParameterIsNotDefault;
                    ToolTip = 'Specifies the value of the Value field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        //-NPR5.40 [308050]
                        Rec.LookupValue();
                        Rec.Modify();
                        SetParameterValue();
                        //+NPR5.40 [308050]
                    end;

                    trigger OnValidate()
                    begin
                        //-NPR5.40 [308050]
                        Rec.Validate(Value, ParameterValue);
                        Rec.Modify();
                        SetParameterValue();
                        //+NPR5.40 [308050]
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Reset Values")
            {
                Caption = 'Reset Values';
                Image = UpdateDescription;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Reset Values action';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        //-NPR5.34 [282915]
        ParameterIsNotDefault := not IsDefault;
        //+NPR5.34 [282915]

        //-NPR5.40 [308050]
        SetParameterName();
        SetParameterDescription();
        SetParameterValue();
        //+NPR5.40 [308050]
    end;

    trigger OnModifyRecord(): Boolean
    begin
        //-NPR5.34 [282915]
        ParameterIsNotDefault := not IsDefault;
        CurrPage.Update(false);
        //+NPR5.34 [282915]
    end;

    var
        ParameterIsNotDefault: Boolean;
        ParameterName: Text;
        ParameterDescription: Text;
        ParameterValue: Text;

    local procedure IsDefault(): Boolean
    var
        POSActionParameter: Record "NPR POS Action Parameter";
    begin
        //-NPR5.34 [282915]
        if POSActionParameter.Get(Rec."Action Code", Rec.Name) then
            exit(POSActionParameter."Default Value" = Rec.Value);
        exit(false);
        //+NPR5.34 [282915]
    end;

    local procedure SetParameterName()
    begin
        //-NPR5.40 [308050]
        Clear(ParameterName);
        Rec.OnGetParameterNameCaption(Rec, ParameterName);
        if (ParameterName = '') then
            ParameterName := Rec.Name;
        //+NPR5.40 [308050]
    end;

    local procedure SetParameterDescription()
    begin
        //-NPR5.40 [308050]
        Clear(ParameterDescription);
        Rec.OnGetParameterDescriptionCaption(Rec, ParameterDescription);
        //+NPR5.40 [308050]
    end;

    local procedure SetParameterValue()
    var
        ParameterOptionString: Text;
    begin
        //-NPR5.40 [308050]
        Clear(ParameterOptionString);
        Clear(ParameterValue);
        Rec.OnGetParameterOptionStringCaption(Rec, ParameterOptionString);
        //-NPR5.54 [335834]
        if Rec."Data Type" = Rec."Data Type"::Boolean then
            ParameterValue := Rec.GetBooleanStringCaption()
        else
            //+NPR5.54 [335834]
            if (ParameterOptionString = '') or (Rec."Data Type" <> Rec."Data Type"::Option) then
                ParameterValue := Rec.Value
            else
                ParameterValue := Rec.GetOptionStringCaption(ParameterOptionString)
        //+NPR5.40 [308050]
    end;
}

