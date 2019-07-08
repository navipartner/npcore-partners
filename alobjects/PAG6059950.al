page 6059950 "Display Setup"
{
    // NPR5.29/CLVA/20170118 CASE 256153 Added functionality OnOpenPage
    //                                   Added field "Image Rotation Interval"
    // NPR5.43/CLVA/20180606 CASE 300254 Added field Activate
    // NPR5.44/CLVA/20180629 CASE 318695 Added field Prices ex. VAT
    // NPR5.46/CLVA/20180920 CASE 328581 Added function InitDisplayContent
    //                                   Removed relation to Codeunit 6059950 Display API
    // NPR5.50/CLVA/20190513 CASE 352390 Added field "Custom Display Codeunit"

    Caption = 'Display Setup';
    PageType = List;
    SourceTable = "Display Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Register No.";"Register No.")
                {
                }
                field("Display Content Code";"Display Content Code")
                {
                }
                field("Screen No.";"Screen No.")
                {
                }
                field("Receipt Duration";"Receipt Duration")
                {
                }
                field("Receipt Width Pct.";"Receipt Width Pct.")
                {
                }
                field("Receipt Placement";"Receipt Placement")
                {
                }
                field("Receipt Description Padding";"Receipt Description Padding")
                {
                }
                field("Receipt Discount Padding";"Receipt Discount Padding")
                {
                }
                field("Receipt Total Padding";"Receipt Total Padding")
                {
                }
                field("Receipt GrandTotal Padding";"Receipt GrandTotal Padding")
                {
                }
                field("Image Rotation Interval";"Image Rotation Interval")
                {
                }
                field("Media Downloaded";"Media Downloaded")
                {
                }
                field("Prices ex. VAT";"Prices ex. VAT")
                {
                }
                field("Custom Display Codeunit";"Custom Display Codeunit")
                {
                }
                field(Activate;Activate)
                {
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
        DisplayContent: Record "Display Content";
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

