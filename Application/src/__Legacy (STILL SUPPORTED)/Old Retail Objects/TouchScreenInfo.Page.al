page 6014530 "NPR Touch Screen - Info"
{
    // NPR4.14/RMT/20150814 Case 220167 Set page property DataCaptionExpr = '' and DAN caption
    // NPR5.25/TS/20160715 CASE 246320 Changed from ListPart to List
    // NPR5.39/TJ  /20180208 CASE 302634 Removed unused variables

    Caption = 'Touch Screen - Info';
    DataCaptionExpression = '';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR TEMP Buffer";

    layout
    {
        area(content)
        {
            repeater(Control6150618)
            {
                ShowCaption = false;
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    StyleExpr = Description1Style;
                    Visible = Col1Visible;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Description 2"; "Description 2")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    StyleExpr = Description2Style;
                    Visible = Col1Visible;
                    ToolTip = 'Specifies the value of the Description 2 field';
                }
                field("Description 3"; "Description 3")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    StyleExpr = Description3Style;
                    Visible = Col1Visible;
                    ToolTip = 'Specifies the value of the Description 3 field';
                }
                field("Description 4"; "Description 4")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    StyleExpr = Description3Style;
                    Visible = Col1Visible;
                    ToolTip = 'Specifies the value of the Description 4 field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetLineStyle;
    end;

    trigger OnOpenPage()
    begin
        Col1Visible := true;
        Col2Visible := true;
        Col3Visible := true;
        Col4Visible := true;
    end;

    var
        Description1Style: Text;
        Description2Style: Text;
        Description3Style: Text;
        Description4Style: Text;
        Col1Visible: Boolean;
        Col2Visible: Boolean;
        Col3Visible: Boolean;
        Col4Visible: Boolean;

    procedure update()
    begin
        //update
        CurrPage.Update(false);
    end;

    procedure SetLineStyle()
    begin
        if Bold then
            Description1Style := 'Strong'
        else
            if Color > 0 then
                Description1Style := 'Attention'
            else
                Description1Style := 'Normal';

        if "Bold 2" then
            Description2Style := 'Strong'
        else
            if "Color 2" > 0 then
                Description2Style := 'Attention'
            else
                Description2Style := 'Normal';

        if "Bold 3" then
            Description3Style := 'Strong'
        else
            if "Color 3" > 0 then
                Description3Style := 'Attention'
            else
                Description3Style := 'Normal';


        if "Bold 4" then
            Description4Style := 'Strong'
        else
            if "Color 4" > 0 then
                Description4Style := 'Attention'
            else
                Description4Style := 'Normal';
    end;
}

