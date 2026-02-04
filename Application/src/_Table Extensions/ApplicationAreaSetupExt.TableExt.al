tableextension 6014680 "NPR Application Area Setup Ext" extends "Application Area Setup"
{
    fields
    {
        field(6060100; "NPR Ticket Essential"; Boolean)
        {
            Caption = 'NaviPartner Ticket Essential';
            DataClassification = CustomerContent;
        }
        field(6060101; "NPR Ticket Advanced"; Boolean)
        {
            Caption = 'NaviPartner Ticket Advanced';
            DataClassification = CustomerContent;
        }
        field(6060102; "NPR Ticket Wallet"; Boolean)
        {
            Caption = 'NaviPartner Ticket Wallet';
            DataClassification = CustomerContent;
        }
        field(6060103; "NPR Ticket Dynamic Price"; Boolean)
        {
            Caption = 'NaviPartner Ticket Dynamic Price';
            DataClassification = CustomerContent;
        }
        field(6060104; "NPR Retail"; Boolean)
        {
            Caption = 'NaviPartner Retail';
            DataClassification = CustomerContent;
        }
        field(6060105; "NPR NaviConnect"; Boolean)
        {
            Caption = 'NaviPartner NaviConnect';
            DataClassification = CustomerContent;
        }
        field(6060106; "NPR Membership Essential"; Boolean)
        {
            Caption = 'NaviPartner Membership Essential';
            DataClassification = CustomerContent;
        }
        field(6060107; "NPR Membership Advanced"; Boolean)
        {
            Caption = 'NaviPartner Membership Advanced';
            DataClassification = CustomerContent;
        }
        field(6060108; "NPR HeyLoyalty"; Boolean)
        {
            Caption = 'NaviPartner HeyLoyalty Integration';
            DataClassification = CustomerContent;
        }
        field(6014402; "NPR Legacy Email"; Boolean)
        {
            Caption = 'NaviPartner Legacy Email';
            DataClassification = CustomerContent;
        }
        field(6014401; "NPR NP Email"; Boolean)
        {
            Caption = 'NaviPartner NP Email';
            DataClassification = CustomerContent;
        }
        field(6014403; "NPR NP Email Templ"; Boolean)
        {
            Caption = 'NaviPartenr NP Email Templates';
            DataClassification = CustomerContent;
        }
        field(6060109; "NPR RS Local"; Boolean)
        {
            Caption = 'NaviPartner RS Localization';
            DataClassification = CustomerContent;
        }
        field(6060110; "NPR RS R Local"; Boolean)
        {
            Caption = 'NaviPartner RS Retail Localization';
            DataClassification = CustomerContent;
        }
        field(6060111; "NPR RS Fiscal"; Boolean)
        {
            Caption = 'NaviPartner RS Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060112; "NPR CRO Fiscal"; Boolean)
        {
            Caption = 'NaviPartner CRO Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060113; "NPR NO Fiscal"; Boolean)
        {
            Caption = 'NaviPartner NO Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060114; "NPR SI Fiscal"; Boolean)
        {
            Caption = 'NaviPartner SI Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060115; "NPR BG Fiscal"; Boolean)
        {
            Caption = 'NaviPartner BG Fiscalization';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-11-28';
            ObsoleteReason = 'SIS Integration specific field is introduced.';
        }
        field(6060116; "NPR BG SIS Fiscal"; Boolean)
        {
            Caption = 'NaviPartner BG SIS Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060117; "NPR IT Fiscal"; Boolean)
        {
            Caption = 'NaviPartner IT Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060118; "NPR DK Fiscal"; Boolean)
        {
            Caption = 'NaviPartner DK Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060119; "NPR HU MultiSoft EInv"; Boolean)
        {
            Caption = 'NaviPartner HU MultiSoft EInv';
            DataClassification = CustomerContent;
        }
#if not BC17
        field(6060120; "NPR Shopify"; Boolean)
        {
            Caption = 'NaviPartner Shopify Integration';
            DataClassification = CustomerContent;
        }
#endif
        field(6060121; "NPR SE CleanCash"; Boolean)
        {
            Caption = 'NaviPartner SE CleanCash';
            DataClassification = CustomerContent;
        }
        field(6014400; "NPR AT Fiscal"; Boolean)
        {
            Caption = 'NaviPartner AT Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060122; "NPR ES Fiscal"; Boolean)
        {
            Caption = 'NaviPartner ES Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060123; "NPR RS EInvoice"; Boolean)
        {
            Caption = 'NaviPartner RS E-Invoice';
            DataClassification = CustomerContent;
        }
        field(6060124; "NPR Obsolete POS Scenarios"; Boolean)
        {
            Caption = 'NaviPartner Obsolete POS Scenarios';
            DataClassification = CustomerContent;
        }
        field(6060125; "NPR New POS Editor"; Boolean)
        {
            Caption = 'NaviPartner New POS Editor';
            DataClassification = CustomerContent;
        }
        field(6060126; "NPR BE Fiscal"; Boolean)
        {
            Caption = 'NaviPartner BE Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060127; "NPR DE Fiscal"; Boolean)
        {
            Caption = 'NaviPartner DE Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060128; "NPR HU Laurel Fiscal"; Boolean)
        {
            Caption = 'NaviPartner HU Laurel Fiscalization';
            DataClassification = CustomerContent;
        }
        field(6060129; "NPR Magento"; Boolean)
        {
            Caption = 'NaviPartner Magento Integration';
            DataClassification = CustomerContent;
        }

        field(6060130; "NPR MemberImagesInCloudflare"; Boolean)
        {
            Caption = 'NaviPartner Member Images in Cloudflare R2 storage';
            DataClassification = CustomerContent;
        }
        field(6060140; "NPR Shopify Ecommerce"; Boolean)
        {
            Caption = 'NaviPartner Shopify Ecommerce Order Experience';
            DataClassification = CustomerContent;
        }
        field(6060150; "NPR Old Restaurant Print Exp"; Boolean)
        {
            Caption = 'NaviPartner Old Restaurant Print Experience';
            DataClassification = CustomerContent;
        }
        field(6060160; "NPR New Restaurant Print Exp"; Boolean)
        {
            Caption = 'NaviPartner New Restaurant Print Experience';
            DataClassification = CustomerContent;
        }
    }
}