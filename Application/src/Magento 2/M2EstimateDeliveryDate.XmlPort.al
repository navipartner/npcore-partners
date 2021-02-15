xmlport 6151138 "NPR M2 Estimate Delivery Date"
{
    Caption = 'Estimate Delivery Date';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(EstimateDeliveryDate)
        {
            textelement(Request)
            {
                MaxOccurs = Once;
                textelement(requestitems)
                {
                    MaxOccurs = Once;
                    XmlName = 'Items';
                    tableelement(tmpitemrequest; "Item Budget Buffer")
                    {
                        XmlName = 'Item';
                        UseTemporary = true;
                        fieldattribute(ItemNumber; TmpItemRequest."Item No.")
                        {
                        }
                        fieldattribute(CustomerNumber; TmpItemRequest."Source No.")
                        {
                        }
                        fieldattribute(ReferenceDate; TmpItemRequest.Date)
                        {
                            Occurrence = Optional;
                        }
                    }
                }
            }
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(Status)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                    }
                }
                textelement(Items)
                {
                    tableelement(tmpitemresponse; "Item Budget Buffer")
                    {
                        XmlName = 'Item';
                        UseTemporary = true;
                        fieldattribute(ItemNumber; TmpItemResponse."Item No.")
                        {
                        }
                        fieldattribute(CustomerNumber; TmpItemResponse."Source No.")
                        {
                        }
                        fieldattribute(ReferenceDate; TmpItemResponse.Date)
                        {
                        }
                        textelement(estimatedatefromvendor)
                        {
                            XmlName = 'FromVendor';
                            textattribute(fromvendorcode)
                            {
                                XmlName = 'VendorCode';
                            }
                        }
                        textelement(estimateddatefromlocation)
                        {
                            XmlName = 'FromLocation';
                            textattribute(fromlocationcode)
                            {
                                XmlName = 'LocationCode';
                            }
                        }

                        trigger OnAfterGetRecord()
                        begin

                            M2ServiceLibrary.GetEstimatedDeliveryDate(TmpItemResponse."Item No.", TmpItemResponse."Source No.", TmpItemResponse.Date, EstimateDateFromVendor, FromVendorCode, EstimatedDateFromLocation, FromLocationCode);
                        end;
                    }
                }
            }
        }
    }

    var
        M2ServiceLibrary: Codeunit "NPR M2 Service Lib.";

    procedure PrepareResult()
    var
        Item: Record Item;
        Customer: Record Customer;
    begin

        ResponseCode := 'OK';
        ResponseMessage := '';

        repeat
            if (Item.Get(TmpItemRequest."Item No.")) and (Customer.Get(TmpItemRequest."Source No.")) then begin
                if (Customer."Location Code" <> '') then begin
                    TmpItemResponse.TransferFields(TmpItemRequest);
                    if (TmpItemResponse.Date = 0D) then
                        TmpItemResponse.Date := Today;
                    TmpItemResponse.Insert();
                end;
            end;
        until (TmpItemRequest.Next() = 0);

        if (TmpItemResponse.IsEmpty()) then begin
            ResponseCode := 'ERROR';
            ResponseMessage := 'The request did not return a result.';
        end;
    end;
}