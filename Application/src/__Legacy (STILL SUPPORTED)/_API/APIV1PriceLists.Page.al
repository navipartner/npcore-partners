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
                    Caption = 'Id', Locked = true;
                }
                field("code"; Rec."Code")
                {
                    Caption = 'Code', Locked = true;
                }
                field(priceType; Rec."Price Type")
                {
                    Caption = 'Price Type', Locked = true;
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description', Locked = true;
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Applies-to Type', Locked = true;
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Applies-to No.', Locked = true;
                }
                field(sourceID; Rec."Source ID")
                {
                    Caption = 'Source ID', Locked = true;
                }
                field(currencyCode; Rec."Currency Code")
                {
                    Caption = 'Currency Code', Locked = true;
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting Date', Locked = true;
                }
                field(endingDate; Rec."Ending Date")
                {
                    Caption = 'Ending Date', Locked = true;
                }
                field(vatBusPostingGrPrice; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    Caption = 'VAT Bus. Posting Gr. (Price)', Locked = true;
                }
                field(priceIncludesVat; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes VAT', Locked = true;
                }
                field(amountType; Rec."Amount Type")
                {
                    Caption = 'Defines', Locked = true;
                }
                field(allowInvoiceDisc; Rec."Allow Invoice Disc.")
                {
                    Caption = 'Allow Invoice Disc.', Locked = true;
                }
                field(allowLineDisc; Rec."Allow Line Disc.")
                {
                    Caption = 'Allow Line Disc.', Locked = true;
                }
                field(sourceGroup; Rec."Source Group")
                {
                    Caption = 'Applies-to Group', Locked = true;
                }
                field(parentSourceNo; Rec."Parent Source No.")
                {
                    Caption = 'Parent Source No.', Locked = true;
                }

                field(filterSourceNo; Rec."Filter Source No.")
                {
                    Caption = 'Filter Source No.', Locked = true;
                }

                field(noSeries; Rec."No. Series")
                {
                    Caption = 'No. Series', Locked = true;
                }
#IF NOT (BC17 or BC18 or BC19)
                field(allowUpdatingDefaults; Rec."Allow Updating Defaults")
                {
                    Caption = 'Allow Updating Defaults', Locked = true;
                }
                field(assignToNo; Rec."Assign-to No.")
                {
                    Caption = 'Assign-to No.', Locked = true;
                }
                field(assignToParentNo; Rec."Assign-to Parent No.")
                {
                    Caption = 'Assign-to Parent No.', Locked = true;
                }
#ENDIF
                field(nprLocationCode; Rec."NPR Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                }
                field(nprRetailPriceList; Rec."NPR Retail Price List")
                {
                    Caption = 'Retail Price List', Locked = true;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date', Locked = true;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                    ObsoleteState = Pending;
                    ObsoleteTag = '2023-06-28';
                    ObsoleteReason = 'Replaced by SystemRowVersion';
                }
#IF NOT (BC17 or BC18 or BC19 or BC20)
                field(systemRowVersion; Rec.SystemRowVersion)
                {
                    Caption = 'systemRowVersion', Locked = true;
                }
#ENDIF

                part(priceListLines; "NPR API V1 - Price List Lines")
                {
                    Caption = 'Lines', Locked = true;
                    EntityName = 'priceListLine';
                    EntitySetName = 'priceListLines';
                    SubPageLink = "NPR Price List Id" = Field(SystemId);
                }
            }
        }
    }

    trigger OnInit()
    begin
#IF (BC17 OR BC18 OR BC19 OR BC20 OR BC21)
        CurrentTransactionType := TransactionType::Update;
#ELSE
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
#ENDIF
    end;

}
