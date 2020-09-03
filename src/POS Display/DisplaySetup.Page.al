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
                }
                field("Display Content Code"; "Display Content Code")
                {
                    ApplicationArea = All;
                }
                field("Screen No."; "Screen No.")
                {
                    ApplicationArea = All;
                }
                field("Receipt Duration"; "Receipt Duration")
                {
                    ApplicationArea = All;
                }
                field("Receipt Width Pct."; "Receipt Width Pct.")
                {
                    ApplicationArea = All;
                }
                field("Receipt Placement"; "Receipt Placement")
                {
                    ApplicationArea = All;
                }
                field("Receipt Description Padding"; "Receipt Description Padding")
                {
                    ApplicationArea = All;
                }
                field("Receipt Discount Padding"; "Receipt Discount Padding")
                {
                    ApplicationArea = All;
                }
                field("Receipt Total Padding"; "Receipt Total Padding")
                {
                    ApplicationArea = All;
                }
                field("Receipt GrandTotal Padding"; "Receipt GrandTotal Padding")
                {
                    ApplicationArea = All;
                }
                field("Image Rotation Interval"; "Image Rotation Interval")
                {
                    ApplicationArea = All;
                }
                field("Media Downloaded"; "Media Downloaded")
                {
                    ApplicationArea = All;
                }
                field("Prices ex. VAT"; "Prices ex. VAT")
                {
                    ApplicationArea = All;
                }
                field("Custom Display Codeunit"; "Custom Display Codeunit")
                {
                    ApplicationArea = All;
                }
                field(Activate; Activate)
                {
                    ApplicationArea = All;
                }
                field("Hide receipt"; "Hide receipt")
                {
                    ApplicationArea = All;
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

