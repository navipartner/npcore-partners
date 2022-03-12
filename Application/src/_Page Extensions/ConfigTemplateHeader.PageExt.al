pageextension 6014402 "NPR Config. Template Header" extends "Config. Template Header"
{
    layout
    {
        modify(ConfigTemplateSubform)
        {
            Visible = false;
            Enabled = false;
        }
        addafter(ConfigTemplateSubform)
        {
            part(NPRConfigTemplateSubform; "Config. Template Subform")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Data Template Code" = FIELD(Code), "NPR Aux Table ID" = const(0);
                SubPageView = SORTING("Data Template Code", "Line No.")
                              ORDER(Ascending);
            }
            part("NPR Aux Conf. Template Subform"; "NPR Aux Conf. Template Subform")
            {
                ApplicationArea = All;
                Visible = IsAuxLinesVisible;
                Enabled = IsAuxLinesVisible;
                SubPageLink = "Data Template Code" = FIELD(Code);
                SubPageView = SORTING("Data Template Code", "Line No.")
                              ORDER(Ascending);
            }
        }
    }
    var
        IsAuxLinesVisible: Boolean;

    trigger OnAfterGetRecord()
    var
        AuxTablesMgt: Codeunit "NPR Aux. Tables Mgt.";
    begin
        CurrPage."NPR Aux Conf. Template Subform".Page.SetAuxTableId(AuxTablesMgt.GetAuxTableIdFromParentTable(Rec."Table ID"));
        IsAuxLinesVisible := AuxTablesMgt.GetAuxTableIdFromParentTable(Rec."Table ID") <> 0;
    end;
}