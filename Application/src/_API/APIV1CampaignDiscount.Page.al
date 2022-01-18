page 6014470 "NPR APIV1 - Campaign Discount"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Period Discount';
    DelayedInsert = true;
    EntityName = 'periodDiscount';
    EntitySetName = 'periodDiscounts';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "NPR Period Discount";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(blockCustomDisc; Rec."Block Custom Disc.")
                {
                    Caption = 'blockCustomDisc', Locked = true;
                }
                field(createdDate; Rec."Created Date")
                {
                    Caption = 'createdDate', Locked = true;
                }
                field(customerDiscGroupFilter; Rec."Customer Disc. Group Filter")
                {
                    Caption = 'customerDiscGroupFilter', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'startingDate', Locked = true;
                }
                field(startingTime; Rec."Starting Time")
                {
                    Caption = 'startingTime', Locked = true;
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'endingDate', Locked = true;
                }
                field(endingTime; Rec."Ending Time")
                {
                    Caption = 'endingTime', Locked = true;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'globalDimension1Code', Locked = true;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'globalDimension2Code', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'locationCode', Locked = true;
                }
                field(noSeries; Rec."No. Series")
                {
                    Caption = 'noSeries', Locked = true;
                }
                field(periodDescription; Rec."Period Description")
                {
                    Caption = 'periodDescription', Locked = true;
                }
                field(periodType; Rec."Period Type")
                {
                    Caption = 'periodType', Locked = true;
                }
                field(quantitySold; Rec."Quantity Sold")
                {
                    Caption = 'quantitySold', Locked = true;
                }
                field(turnover; Rec.Turnover)
                {
                    Caption = 'turnover', Locked = true;
                }
                field(monday; Rec.Monday)
                {
                    Caption = 'monday', Locked = true;
                }
                field(tuesday; Rec.Tuesday)
                {
                    Caption = 'tuesday', Locked = true;
                }
                field(wednesday; Rec.Wednesday)
                {
                    Caption = 'wednesday', Locked = true;
                }
                field(thursday; Rec.Thursday)
                {
                    Caption = 'thursday', Locked = true;
                }
                field(friday; Rec.Friday)
                {
                    Caption = 'friday', Locked = true;
                }
                field(saturday; Rec.Saturday)
                {
                    Caption = 'saturday', Locked = true;
                }
                field(sunday; Rec.Sunday)
                {
                    Caption = 'sunday', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'status', Locked = true;
                }
                field(lastDateModified; Rec."Last Date Modified")
                {
                    Caption = 'Last Date Modified', Locked = true;
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'systemModifiedAt', Locked = true;
                }
                field(replicationCounter; Rec."Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

                part(periodDiscountLines; "NPR APIV1 - Camp. Disc. Lines")
                {
                    Caption = 'Period Discount Lines';
                    EntityName = 'periodDiscountLine';
                    EntitySetName = 'periodDiscountLines';
                    SubPageLink = Code = field(Code);
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
