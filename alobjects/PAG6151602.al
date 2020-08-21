page 6151602 "NpDc Coupon Setup"
{
    // NPR5.34/MHA /20170725  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon
    // NPR5.37/MHA /20171016  CASE 293531 Added Actions: How-to Videos
    // NPR5.40/MHA /20180323  CASE 305859 Added fields 25 "Reference No. Pattern" and 30 "Print Template Code"
    // NPR5.42/MHA /20180521  CASE 305859 Added field 35 Print on Issue

    Caption = 'Coupon Setup';
    PageType = Card;
    SourceTable = "NpDc Coupon Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Coupon No. Series"; "Coupon No. Series")
                {
                    ApplicationArea = All;
                }
                field("Arch. Coupon No. Series"; "Arch. Coupon No. Series")
                {
                    ApplicationArea = All;
                }
                field("Reference No. Pattern"; "Reference No. Pattern")
                {
                    ApplicationArea = All;
                }
                field("Print Template Code"; "Print Template Code")
                {
                    ApplicationArea = All;
                }
                field("Print on Issue"; "Print on Issue")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("How-to Videos")
            {
                Caption = 'How-to Videos';
                Image = UserInterface;

                trigger OnAction()
                var
                    EmbeddedVideoMgt: Codeunit "Embedded Video Mgt.";
                begin
                    EmbeddedVideoMgt.ShowEmbeddedVideos('NPDC');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Get then
            Insert;
    end;
}

