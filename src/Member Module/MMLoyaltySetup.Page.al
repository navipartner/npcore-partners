page 6060105 "NPR MM Loyalty Setup"
{

    Caption = 'Loyalty Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Loyalty Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Collection Period"; "Collection Period")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Fixed Period Start"; "Fixed Period Start")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Collection Period Length"; "Collection Period Length")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Expire Uncollected Points"; "Expire Uncollected Points")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin

                        CurrPage.Update(true);

                    end;
                }
                field("Expire Uncollected After"; "Expire Uncollected After")
                {
                    ApplicationArea = All;

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

                    trigger OnValidate()
                    var
                        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
                    begin

                        LoyaltyPointManagement.CalcultatePointsValidPeriod(Rec, TestDate, CollectionPeriodStart, CollectionPeriodEnd);
                        CurrPage.Update(true);

                    end;
                }
                field(CollectionPeriodStart; CollectionPeriodStart)
                {
                    ApplicationArea = All;
                    Caption = 'Earn Period Start';
                    Editable = false;
                }
                field(CollectionPeriodEnd; CollectionPeriodEnd)
                {
                    ApplicationArea = All;
                    Caption = 'Earn Period End';
                    Editable = false;
                }
                field(ExpirePointsAt; ExpirePointsAt)
                {
                    ApplicationArea = All;
                    Caption = 'Expire Points At';
                    Editable = false;
                }
                field("Voucher Point Source"; "Voucher Point Source")
                {
                    ApplicationArea = All;
                }
                field("Voucher Point Threshold"; "Voucher Point Threshold")
                {
                    ApplicationArea = All;
                }
                field("Voucher Creation"; "Voucher Creation")
                {
                    ApplicationArea = All;
                }
                field("Point Base"; "Point Base")
                {
                    ApplicationArea = All;
                }
                field("Amount Base"; "Amount Base")
                {
                    ApplicationArea = All;
                }
                field("Points On Discounted Sales"; "Points On Discounted Sales")
                {
                    ApplicationArea = All;
                }
                field("Amount Factor"; "Amount Factor")
                {
                    ApplicationArea = All;
                }
                field("Point Rate"; "Point Rate")
                {
                    ApplicationArea = All;
                }
                field("Auto Upgrade Point Source"; "Auto Upgrade Point Source")
                {
                    ApplicationArea = All;
                }
                field(ReasonText; ReasonText)
                {
                    ApplicationArea = All;
                    Caption = 'ReasonText';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;
                    Visible = false;
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
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loyalty Point Setup";
                RunPageLink = Code = FIELD(Code);
                ApplicationArea = All;
            }
            action("Item Points Setup")
            {
                Caption = 'Item Points Setup';
                Ellipsis = true;
                Image = CalculateInvoiceDiscount;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loy. Item Point Setup";
                RunPageLink = Code = FIELD(Code);
                ApplicationArea = All;
            }
            separator(Separator6014432)
            {
            }
            action("Auto Upgrade Thresholds")
            {
                Caption = 'Auto Upgrade Threshold';
                Image = UserCertificate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loyalty Alter Members.";
                RunPageLink = "Loyalty Code" = FIELD(Code);
                ApplicationArea = All;
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
                }
                action("(Client) Loyalty Server Endpoints")
                {
                    Caption = '(Client) Loyalty Server Endpoints';
                    Image = Server;
                    RunObject = Page "NPR MM NPR Endpoint Setup";
                    ApplicationArea = All;
                }
                action("(Client) Loyalty Server - Store Setup")
                {
                    Caption = '(Client) Loyalty Server - Store Setup';
                    Image = NumberSetup;
                    RunObject = Page "NPR MM Loy. Store Setup Client";
                    ApplicationArea = All;
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
            LoyaltyPointManagement.CalcultatePointsValidPeriod(Rec, TestDate, CollectionPeriodStart, CollectionPeriodEnd);

            ExpirePointsAt := 0D;
            if ("Expire Uncollected Points") then
                if (Format("Expire Uncollected After") <> '') then
                    if (CollectionPeriodEnd <> 0D) then
                        ExpirePointsAt := CalcDate("Expire Uncollected After", CollectionPeriodEnd);

            PeriodCalculationIssue := not LoyaltyPointManagement.ValidateFixedPeriodCalculation(Rec, ReasonText);
        end;

        if (Rec."Collection Period" = Rec."Collection Period"::AS_YOU_GO) then begin
            if ("Expire Uncollected Points") then
                if (Format("Expire Uncollected After") <> '') then
                    ExpirePointsAt := CalcDate("Expire Uncollected After", Today);
        end;

    end;

    trigger OnInit()
    begin
        TestDate := Today;
    end;

    var
        CollectionPeriodStart: Date;
        CollectionPeriodEnd: Date;
        ExpirePointsAt: Date;
        TestDate: Date;
        DF_PROBLEM_PREV: Label 'Check your dateformulas - the previous period is not calculating correctly.';
        DF_PROBLEM_NEXT: Label 'Check your dateformulas - the next period is not calculating correctly.';
        PeriodCalculationIssue: Boolean;
        ReasonText: Text;

    local procedure ExpirePoints()
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        LoyaltyPointManagement.ExpireFixedPeriodPoints(Rec.Code);
    end;
}

