report 6060130 "MM Membership Points Value"
{
    // MM1.17/JLK /20170123  CASE 243075 Object created
    DefaultLayout = RDLC;
    RDLCLayout = './layouts/MM Membership Points Value.rdlc';

    Caption = 'Membership Points Summary';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem("MM Membership";"MM Membership")
        {
            RequestFilterFields = "Membership Code";
            column(MembershipCode_MMMembership;"Membership Code")
            {
            }
            column(MembershipNoCaption;MembershipNoCaption)
            {
            }
            column(ExtMembershipNo_MMMMembership;"External Membership No.")
            {
            }
            column(CustomerNo_MMMembership;"Customer No.")
            {
                IncludeCaption = true;
            }
            column(Name_Customer;CustomerName)
            {
            }
            column(Name_CustomerCaption;Customer.FieldCaption(Name))
            {
            }
            column(RemainingPoints_MMMembership;"Remaining Points")
            {
            }
            column(TotalPointsCaption;TotalPointsCaption)
            {
            }
            column(PageCaption;PageCaption)
            {
            }
            column(GetFilters;GetFilters)
            {
            }
            column(PointsToRedeemCaption;PointsToRedeemCaption)
            {
            }
            column(PointDistributionCaption;PointDistributionCaption)
            {
            }
            column(DescriptionCaption;DescriptionCaption)
            {
            }
            column(ValueCaption;ValueCaption)
            {
            }
            column(TotalValueCaption;TotalValueCaption)
            {
            }
            dataitem("MM Membership Setup";"MM Membership Setup")
            {
                DataItemLink = Code=FIELD("Membership Code");
                DataItemTableView = SORTING(Code);
                dataitem("MM Loyalty Setup";"MM Loyalty Setup")
                {
                    DataItemLink = Code=FIELD("Loyalty Code");
                    DataItemTableView = SORTING(Code);
                    dataitem("MM Loyalty Points Setup";"MM Loyalty Points Setup")
                    {
                        DataItemLink = Code=FIELD(Code);
                        DataItemTableView = SORTING(Code,"Line No.");

                        trigger OnAfterGetRecord()
                        begin
                            TempSortedLoyaltyPoints.Init;
                            TempSortedLoyaltyPoints.Template := Code;
                            TempSortedLoyaltyPoints."Line No." := "Line No.";
                            TempSortedLoyaltyPoints.Indent := "Points Threshold";
                            TempSortedLoyaltyPoints.Description := Description;
                            TempSortedLoyaltyPoints."Decimal 1" := "Amount LCY";
                            TempSortedLoyaltyPoints.Insert;
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempSortedLoyaltyPoints.DeleteAll;
                        end;
                    }
                    dataitem(TempSortedLoyaltyPoints;"NPR - TEMP Buffer")
                    {
                        DataItemTableView = SORTING(Indent) ORDER(Descending);
                        UseTemporary = true;
                        column(PointDistribution;PointDistribution)
                        {
                        }
                        column(TotalPoints;TotalPoints)
                        {
                        }
                        column(PointsToRedeem;PointsToRedeem)
                        {
                        }
                        column(PerPointDistributionCount;PerPointDistributionCount)
                        {
                        }
                        column(PerPointDistributionValue;PerPointDistributionValue)
                        {
                        }
                        column(TotalPointDistributionValue;TotalPointDistributionValue)
                        {
                        }
                        column(Description;Description)
                        {
                        }
                        column(Indent;Indent)
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            i: Integer;
                            LoopCount: Integer;
                        begin

                            if (TotalPoints - Indent) < 0 then
                              CurrReport.Skip;

                            PerPointDistributionCount := 0;
                            PointDistribution := 0;
                            LoopCount := (TotalPoints div Indent);
                            if LoopCount = 0 then
                              CurrReport.Skip;

                            for i := 1 to LoopCount do begin
                              TotalPoints := TotalPoints - Indent;
                              PerPointDistributionCount := PerPointDistributionCount  + 1;
                              PointDistribution += Indent;
                              PointsToRedeem += Indent;
                            end;

                            PerPointDistributionValue := PerPointDistributionCount * "Decimal 1";
                            TotalPointDistributionValue += PerPointDistributionValue;

                            if TempLoyaltyPointsPerMembership.Get(TempSortedLoyaltyPoints.Template,TempSortedLoyaltyPoints."Line No.") then begin
                              TempLoyaltyPointsPerMembership.Indent += PointDistribution;
                              TempLoyaltyPointsPerMembership."Decimal 1" += PerPointDistributionValue;
                              TempLoyaltyPointsPerMembership.Modify;
                            end else begin
                              TempLoyaltyPointsPerMembership.Init;
                              TempLoyaltyPointsPerMembership.TransferFields(TempSortedLoyaltyPoints);
                              TempLoyaltyPointsPerMembership.Indent := PointDistribution;
                              TempLoyaltyPointsPerMembership."Decimal 1" := PerPointDistributionValue;
                              TempLoyaltyPointsPerMembership.Insert;
                            end;
                        end;

                        trigger OnPreDataItem()
                        begin
                            if TempSortedLoyaltyPoints.IsEmpty then
                              CurrReport.Break;

                            TotalPoints := "MM Membership"."Remaining Points";
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if "MM Loyalty Setup"."Voucher Point Threshold" > "MM Membership"."Remaining Points" then
                          CurrReport.Break;
                    end;
                }
            }
            dataitem(TempLoyaltyPointsPerMembership;"NPR - TEMP Buffer")
            {
                DataItemTableView = SORTING(Indent);
                UseTemporary = true;
                column(Template;Template)
                {
                }
                column(LineNo;"Line No.")
                {
                }
                column(TotalPointDistribution;Indent)
                {
                }
                column(PerPointDescription;Description)
                {
                }
                column(TotalPerPointDistribution;"Decimal 1")
                {
                }

                trigger OnAfterGetRecord()
                begin
                    SumPointsToRedeem += Indent;
                    SumPointDistributionValue += "Decimal 1";
                end;
            }
            dataitem("Integer";"Integer")
            {
                DataItemTableView = SORTING(Number) WHERE(Number=CONST(1));
                column(SumRemainingPoints;SumRemainingPoints)
                {
                }
                column(SumPointsToRedeem;SumPointsToRedeem)
                {
                }
                column(SumPointDistruibutionValue;SumPointDistributionValue)
                {
                }
            }

            trigger OnAfterGetRecord()
            begin

                CalcFields("Awarded Points (Sale)","Awarded Points (Refund)","Redeemed Points (Withdrawl)","Redeemed Points (Deposit)","Expired Points","Remaining Points");

                Clear(CustomerName);
                if Customer.Get("Customer No.") then
                  CustomerName := Customer.Name;

                PointsToRedeem := 0;
                PerPointDistributionValue := 0;
                TotalPointDistributionValue := 0;
                TempLoyaltyPointsPerMembership.DeleteAll;
                SumRemainingPoints += "MM Membership"."Remaining Points";
            end;

            trigger OnPreDataItem()
            begin

                SumPointsToRedeem := 0;
                SumRemainingPoints := 0;
                SumPointDistributionValue := 0;
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            "MM Membership".SetFilter("Date Filter",'..%2',Today);
        end;
    }

    labels
    {
        ReportLbl = 'Membership Points Summary';
    }

    var
        Customer: Record Customer;
        CustomerName: Text;
        PageCaption: Label 'Page %1 of %2';
        PointDistribution: Decimal;
        TotalPoints: Decimal;
        PointsToRedeem: Decimal;
        PerPointDistributionCount: Decimal;
        PerPointDistributionValue: Decimal;
        TotalPointDistributionValue: Decimal;
        PointsToRedeemCaption: Label 'Points to Redeem';
        PointDistributionCaption: Label 'Point Distribution';
        DescriptionCaption: Label 'Description';
        ValueCaption: Label 'Value';
        TotalValueCaption: Label 'Total Value';
        TotalPointsCaption: Label 'Total Points';
        SumRemainingPoints: Decimal;
        SumPointsToRedeem: Decimal;
        SumPointDistributionValue: Decimal;
        MembershipNoCaption: Label 'Membership';
}

