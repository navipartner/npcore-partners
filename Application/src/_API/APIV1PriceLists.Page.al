page 6014544 "NPR API V1 - Price Lists"
{

    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Price Lists';
    DelayedInsert = true;
    EntityName = 'priceList';
    EntitySetName = 'priceLists';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Price List Header";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(priceType; Rec."Price Type")
                {
                    Caption = 'Price Type';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Applies-to Type';
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Applies-to No.';
                }
                field(sourceID; Rec."Source ID")
                {
                    Caption = 'Source ID';
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code';
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date';
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'Ending Date';
                }
                field(vatBusPostingGrPrice; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    Caption = 'VAT Bus. Posting Gr. (Price)';
                }
                field(priceIncludesVat; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes VAT';
                }
                field(amountType; Rec."Amount Type")
                {
                    Caption = 'Defines';
                }
                field(allowInvoiceDisc; Rec."Allow Invoice Disc.")
                {
                    Caption = 'Allow Invoice Disc.';
                }
                field(allowLineDisc; Rec."Allow Line Disc.")
                {
                    Caption = 'Allow Line Disc.';
                }
                field(sourceGroup; Rec."Source Group")
                {
                    Caption = 'Applies-to Group';
                }
                field(parentSourceNo; Rec."Parent Source No.")
                {
                    Caption = 'Parent Source No.';
                }

                field(filterSourceNo; Rec."Filter Source No.")
                {
                    Caption = 'Filter Source No.';
                }

                field(noSeries; Rec."No. Series")
                {
                    Caption = 'No. Series';
                }
                field(systemModifiedAt; Rec.SystemModifiedAt)
                {
                    Caption = 'SystemModifiedAt';
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }

                part(priceListLines; "NPR API V1 - Price List Lines")
                {
                    Caption = 'Lines';
                    EntityName = 'priceListLine';
                    EntitySetName = 'priceListLines';
                    SubPageLink = "NPR Price List Id" = Field(SystemId);
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

}
