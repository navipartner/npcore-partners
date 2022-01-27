page 6060105 "NPR MM Loyalty Setup"
{
    Extensible = False;

    Caption = 'Loyalty Setup';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR MM Loyalty Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Collection Period"; Rec."Collection Period")
                {

                    ToolTip = 'Specifies the value of the Collection Period field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Fixed Period Start"; Rec."Fixed Period Start")
                {

                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;
                    ToolTip = 'Specifies the value of the Fixed Period Start field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Collection Period Length"; Rec."Collection Period Length")
                {

                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;
                    ToolTip = 'Specifies the value of the Collection Period Length field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Expire Uncollected Points"; Rec."Expire Uncollected Points")
                {

                    ToolTip = 'Specifies the value of the Expire Uncollected Points field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Expire Uncollected After"; Rec."Expire Uncollected After")
                {

                    ToolTip = 'Specifies the value of the Expire Uncollected After field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field(TestDate; TestDate)
                {

                    Caption = 'Period Test Date';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Period Test Date field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    var
                        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
                    begin

                        LoyaltyPointManagement.CalculatePointsValidPeriod(Rec, TestDate, CollectionPeriodStart, CollectionPeriodEnd);
                        CurrPage.Update(true);

                    end;
                }
                field(CollectionPeriodStart; CollectionPeriodStart)
                {

                    Caption = 'Earn Period Start';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Earn Period Start field';
                    ApplicationArea = NPRRetail;
                }
                field(CollectionPeriodEnd; CollectionPeriodEnd)
                {

                    Caption = 'Earn Period End';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Earn Period End field';
                    ApplicationArea = NPRRetail;
                }
                field(ExpirePointsAt; ExpirePointsAt)
                {

                    Caption = 'Expire Points At';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Expire Points At field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Point Source"; Rec."Voucher Point Source")
                {

                    ToolTip = 'Specifies the value of the Voucher Point Source field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Point Threshold"; Rec."Voucher Point Threshold")
                {

                    ToolTip = 'Specifies the value of the Voucher Point Threshold field';
                    ApplicationArea = NPRRetail;
                }
                field("Voucher Creation"; Rec."Voucher Creation")
                {

                    ToolTip = 'Specifies the value of the Voucher Creation field';
                    ApplicationArea = NPRRetail;
                }
                field("Point Base"; Rec."Point Base")
                {

                    ToolTip = 'Specifies the value of the Point Base field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Base"; Rec."Amount Base")
                {

                    ToolTip = 'Specifies the value of the Amount Base field';
                    ApplicationArea = NPRRetail;
                }
                field("Points On Discounted Sales"; Rec."Points On Discounted Sales")
                {

                    ToolTip = 'Specifies the value of the Points On Discounted Sales field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Factor"; Rec."Amount Factor")
                {

                    ToolTip = 'Specifies the value of the Amount Factor field';
                    ApplicationArea = NPRRetail;
                }
                field("Rounding on Earning"; Rec."Rounding on Earning")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies how the price * amount factor is rounded when earning points.';
                }
                field("Point Rate"; Rec."Point Rate")
                {

                    ToolTip = 'Specifies the value of the Point Rate field';
                    ApplicationArea = NPRRetail;
                }
                field("Auto Upgrade Point Source"; Rec."Auto Upgrade Point Source")
                {

                    ToolTip = 'Specifies the value of the Auto Upgrade Point Source field';
                    ApplicationArea = NPRRetail;
                }
                field(ReasonText; ReasonText)
                {

                    Caption = 'ReasonText';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;
                    Visible = false;
                    ToolTip = 'Specifies the value of the ReasonText field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Points to Amount Setup")
            {
                Caption = 'Points to Amount Setup';
                Ellipsis = true;
                Image = LineDiscount;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loyalty Point Setup";
                RunPageLink = Code = FIELD(Code);

                ToolTip = 'Executes the Points to Amount Setup action';
                ApplicationArea = NPRRetail;
            }
            action("Item Points Setup")
            {
                Caption = 'Item Points Setup';
                Ellipsis = true;
                Image = CalculateInvoiceDiscount;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loy. Item Point Setup";
                RunPageLink = Code = FIELD(Code);

                ToolTip = 'Executes the Item Points Setup action';
                ApplicationArea = NPRRetail;
            }
            separator(Separator6014432)
            {
            }
            action("Auto Upgrade Thresholds")
            {
                Caption = 'Auto Upgrade Threshold';
                Image = UserCertificate;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loyalty Alter Members.";
                RunPageLink = "Loyalty Code" = FIELD(Code);

                ToolTip = 'Executes the Auto Upgrade Threshold action';
                ApplicationArea = NPRRetail;
            }
            group("Cross Company Loyalty")
            {
                Caption = 'Cross Company Loyalty';
                action("(Server) Loyalty Server - Store Setup")
                {
                    Caption = '(Server) Loyalty Server - Store Setup';
                    Image = Server;
                    RunObject = Page "NPR MM Loy. Store Setup Server";

                    ToolTip = 'Executes the (Server) Loyalty Server - Store Setup action';
                    ApplicationArea = NPRRetail;
                }
                action("(Client) Loyalty Server Endpoints")
                {
                    Caption = '(Client) Loyalty Server Endpoints';
                    Image = Server;
                    RunObject = Page "NPR MM NPR Endpoint Setup";

                    ToolTip = 'Executes the (Client) Loyalty Server Endpoints action';
                    ApplicationArea = NPRRetail;
                }
                action("(Client) Loyalty Server - Store Setup")
                {
                    Caption = '(Client) Loyalty Server - Store Setup';
                    Image = NumberSetup;
                    RunObject = Page "NPR MM Loy. Store Setup Client";

                    ToolTip = 'Executes the (Client) Loyalty Server - Store Setup action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
        area(processing)
        {
            action("Expire Points")
            {
                Caption = 'Expire Points';
                Ellipsis = true;
                Image = Excise;

                ToolTip = 'Executes the Expire Points action';
                ApplicationArea = NPRRetail;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                begin

                    ExpirePoints();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        CollectionPeriodEnd := 0D;
        CollectionPeriodStart := 0D;
        ReasonText := '';
        if (Rec."Collection Period" = Rec."Collection Period"::FIXED) then begin
            LoyaltyPointManagement.CalculatePointsValidPeriod(Rec, TestDate, CollectionPeriodStart, CollectionPeriodEnd);

            ExpirePointsAt := 0D;
            if (Rec."Expire Uncollected Points") then
                if (Format(Rec."Expire Uncollected After") <> '') then
                    if (CollectionPeriodEnd <> 0D) then
                        ExpirePointsAt := CalcDate(Rec."Expire Uncollected After", CollectionPeriodEnd);

            PeriodCalculationIssue := not LoyaltyPointManagement.ValidateFixedPeriodCalculation(Rec, ReasonText);
        end;

        if (Rec."Collection Period" = Rec."Collection Period"::AS_YOU_GO) then begin
            if (Rec."Expire Uncollected Points") then
                if (Format(Rec."Expire Uncollected After") <> '') then
                    ExpirePointsAt := CalcDate(Rec."Expire Uncollected After", Today);
        end;

    end;

    trigger OnInit()
    begin
        TestDate := Today();
    end;

    var
        CollectionPeriodStart: Date;
        CollectionPeriodEnd: Date;
        ExpirePointsAt: Date;
        TestDate: Date;
        PeriodCalculationIssue: Boolean;
        ReasonText: Text;

    local procedure ExpirePoints()
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        LoyaltyPointManagement.ExpireFixedPeriodPoints(Rec.Code);
    end;
}

