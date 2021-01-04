page 6059950 "NPR Display Setup"
{
    // NPR5.29/CLVA/20170118 CASE 256153 Added functionality OnOpenPage
    //                                   Added field "Image Rotation Interval"
    // NPR5.43/CLVA/20180606 CASE 300254 Added field Activate
    // NPR5.44/CLVA/20180629 CASE 318695 Added field Prices ex. VAT
    // NPR5.46/CLVA/20180920 CASE 328581 Added function InitDisplayContent
    //                                   Removed relation to Codeunit 6059950 Display API
    // NPR5.50/CLVA/20190513 CASE 352390 Added field "Custom Display Codeunit"
    // NPR5.51/ANPA/20190722 CASE 352390 Added field "Hide receipt"

    Caption = 'Display Setup';
    PageType = List;
    SourceTable = "NPR Display Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No."; "Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register No. field';
                }
                field("Display Content Code"; "Display Content Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Display Content Code field';
                }
                field("Screen No."; "Screen No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Screen No. field';
                }
                field("Receipt Duration"; "Receipt Duration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Duration field';
                }
                field("Receipt Width Pct."; "Receipt Width Pct.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Width Pct. field';
                }
                field("Receipt Placement"; "Receipt Placement")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Placement field';
                }
                field("Receipt Description Padding"; "Receipt Description Padding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Description Padding field';
                }
                field("Receipt Discount Padding"; "Receipt Discount Padding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Discount Padding field';
                }
                field("Receipt Total Padding"; "Receipt Total Padding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt Total Padding field';
                }
                field("Receipt GrandTotal Padding"; "Receipt GrandTotal Padding")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Receipt GrandTotal Padding field';
                }
                field("Image Rotation Interval"; "Image Rotation Interval")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Image Rotation Interval field';
                }
                field("Media Downloaded"; "Media Downloaded")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Media Downloaded field';
                }
                field("Prices ex. VAT"; "Prices ex. VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prices ex. VAT field';
                }
                field("Custom Display Codeunit"; "Custom Display Codeunit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Custom Display Codeunit field';
                }
                field(Activate; Activate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activate field';
                }
                field("Hide receipt"; "Hide receipt")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Hide receipt field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        //NPR5.29-
        //-NPR5.46 [328581]
        //DisplayAPI.InitDisplayContent;
        InitDisplayContent;
        //+NPR5.46 [328581]
        //NPR5.29+
    end;

    procedure InitDisplayContent()
    var
        DisplayContent: Record "NPR Display Content";
    begin
        //-NPR5.46 [328581]
        if DisplayContent.FindSet then
            exit;

        DisplayContent.Init;
        DisplayContent.Code := 'HTML';
        DisplayContent.Type := DisplayContent.Type::Html;
        DisplayContent.Insert;

        DisplayContent.Init;
        DisplayContent.Code := 'IMAGE';
        DisplayContent.Type := DisplayContent.Type::Image;
        DisplayContent.Insert;

        DisplayContent.Init;
        DisplayContent.Code := 'VIDEO';
        DisplayContent.Type := DisplayContent.Type::Video;
        DisplayContent.Insert;
        //+NPR5.46 [328581]
    end;
}

