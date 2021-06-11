page 6060105 "NPR MM Loyalty Setup"
{

    Caption = 'Loyalty Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MM Loyalty Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Collection Period"; Rec."Collection Period")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Collection Period field';

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Fixed Period Start"; Rec."Fixed Period Start")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;
                    ToolTip = 'Specifies the value of the Fixed Period Start field';

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Collection Period Length"; Rec."Collection Period Length")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;
                    ToolTip = 'Specifies the value of the Collection Period Length field';

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Expire Uncollected Points"; Rec."Expire Uncollected Points")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expire Uncollected Points field';

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Expire Uncollected After"; Rec."Expire Uncollected After")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expire Uncollected After field';

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field(TestDate; TestDate)
                {
                    ApplicationArea = All;
                    Caption = 'Period Test Date';
                    Visible = false;
                    ToolTip = 'Specifies the value of the Period Test Date field';

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
                    ApplicationArea = All;
                    Caption = 'Earn Period Start';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Earn Period Start field';
                }
                field(CollectionPeriodEnd; CollectionPeriodEnd)
                {
                    ApplicationArea = All;
                    Caption = 'Earn Period End';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Earn Period End field';
                }
                field(ExpirePointsAt; ExpirePointsAt)
                {
                    ApplicationArea = All;
                    Caption = 'Expire Points At';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Expire Points At field';
                }
                field("Voucher Point Source"; Rec."Voucher Point Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Point Source field';
                }
                field("Voucher Point Threshold"; Rec."Voucher Point Threshold")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Point Threshold field';
                }
                field("Voucher Creation"; Rec."Voucher Creation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Voucher Creation field';
                }
                field("Point Base"; Rec."Point Base")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Point Base field';
                }
                field("Amount Base"; Rec."Amount Base")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Base field';
                }
                field("Points On Discounted Sales"; Rec."Points On Discounted Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points On Discounted Sales field';
                }
                field("Amount Factor"; Rec."Amount Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Factor field';
                }
                field("Rounding on Earning"; Rec."Rounding on Earning")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how the price * amount factor is rounded when earning points.';
                }
                field("Point Rate"; Rec."Point Rate")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Point Rate field';
                }
                field("Auto Upgrade Point Source"; Rec."Auto Upgrade Point Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Auto Upgrade Point Source field';
                }
                field(ReasonText; ReasonText)
                {
                    ApplicationArea = All;
                    Caption = 'ReasonText';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;
                    Visible = false;
                    ToolTip = 'Specifies the value of the ReasonText field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Points to Amount Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Item Points Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Auto Upgrade Threshold action';
            }
            group("Cross Company Loyalty")
            {
                Caption = 'Cross Company Loyalty';
                action("(Server) Loyalty Server - Store Setup")
                {
                    Caption = '(Server) Loyalty Server - Store Setup';
                    Image = Server;
                    RunObject = Page "NPR MM Loy. Store Setup Server";
                    ApplicationArea = All;
                    ToolTip = 'Executes the (Server) Loyalty Server - Store Setup action';
                }
                action("(Client) Loyalty Server Endpoints")
                {
                    Caption = '(Client) Loyalty Server Endpoints';
                    Image = Server;
                    RunObject = Page "NPR MM NPR Endpoint Setup";
                    ApplicationArea = All;
                    ToolTip = 'Executes the (Client) Loyalty Server Endpoints action';
                }
                action("(Client) Loyalty Server - Store Setup")
                {
                    Caption = '(Client) Loyalty Server - Store Setup';
                    Image = NumberSetup;
                    RunObject = Page "NPR MM Loy. Store Setup Client";
                    ApplicationArea = All;
                    ToolTip = 'Executes the (Client) Loyalty Server - Store Setup action';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Expire Points action';
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

