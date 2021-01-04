page 6151602 "NPR NpDc Coupon Setup"
{
    Caption = 'Coupon Setup';
    PageType = Card;
    SourceTable = "NPR NpDc Coupon Setup";
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    EmbeddedVideoMgt: Codeunit "NPR Embedded Video Mgt.";
                begin
                    EmbeddedVideoMgt.ShowEmbeddedVideos('NPDC');
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;
}

