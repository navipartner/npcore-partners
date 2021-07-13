import { Component } from "react";
import { bindComponentToLocalizationStateFull, MISSING_CAPTION } from "../redux/reducers/localizationReducer";

export const GlobalCaption = {
  Input: {
    InvalidValue: Symbol(),
    ResultIs: Symbol(),
  },
  NotificationTooltips: {
    BusyState: {
      Busy: Symbol(),
      Idle: Symbol(),
    },
    Messages: {
      NoMessages: Symbol(),
      MessagesAvailable: Symbol(),
    },
  },
  Error: Symbol(),

  /**
   * Contains the list of IDs for properties that come from the back end. This is used for strong-typed constant-like
   * translatable caption access.
   *
   * So, instead of:
   * ```javascript
   * localize("Sale_ReceiptNo");
   * ```
   *
   * ... we can write:
   * ```javascript
   * localize(GlobalCaption.FromBackEnd.Sale_ReceiptNo);
   * ```
   *
   * This way it's not necessary to remember or lookup the correct string value to translate. All are accessible through constants.
   */
  FromBackEnd: {
    Sale_ReceiptNo: "Sale_ReceiptNo",
    Sale_EANHeader: "Sale_EANHeader",
    Sale_LastSale: "Sale_LastSale",
    Login_FunctionButtonText: "Login_FunctionButtonText",
    Login_MainMenuButtonText: "Login_MainMenuButtonText",
    Sale_PaymentAmount: "Sale_PaymentAmount",
    Sale_PaymentTotal: "Sale_PaymentTotal",
    Sale_ReturnAmount: "Sale_ReturnAmount",
    Sale_RegisterNo: "Sale_RegisterNo",
    Sale_SalesPersonCode: "Sale_SalesPersonCode",
    Login_Clear: "Login_Clear",
    Sale_SubTotal: "Sale_SubTotal",
    Payment_PaymentInfo: "Payment_PaymentInfo",
    Global_Abort: "Global_Abort",
    Global_Cancel: "Global_Cancel",
    Global_Close: "Global_Close",
    Global_Back: "Global_Back",
    Global_OK: "Global_OK",
    Global_Yes: "Global_Yes",
    Global_No: "Global_No",
    Global_Today: "Global_Today",
    Global_Tomorrow: "Global_Tomorrow",
    Global_Yesterday: "Global_Yesterday",
    Balancing_CashMovements: "Balancing_CashMovements",
    Balancing_Balancing: "Balancing_Balancing",
    Balancing_CreatedAt: "Balancing_CreatedAt",
    Balancing_directItemSalesCount: "Balancing_directItemSalesCount",
    Balancing_directItemReturnCount: "Balancing_directItemReturnCount",
    Balancing_Overview: "Balancing_Overview",
    Balancing_Sales: "Balancing_Sales",
    Balancing_DirectItemSalesLCY: "Balancing_DirectItemSalesLCY",
    Balancing_DirectItemReturnsLCY: "Balancing_DirectItemReturnsLCY",
    Balancing_LocalCurrencyLCY: "Balancing_LocalCurrencyLCY",
    Balancing_ForeignCurrencyLCY: "Balancing_ForeignCurrencyLCY",
    Balancing_OtherPayments: "Balancing_OtherPayments",
    Balancing_DebtorPaymentLCY: "Balancing_DebtorPaymentLCY",
    Balancing_EFTLCY: "Balancing_EFTLCY",
    Balancing_GLPaymentLCY: "Balancing_GLPaymentLCY",
    Balancing_Voucher: "Balancing_Voucher",
    Balancing_RedeemedVouchersLCY: "Balancing_RedeemedVouchersLCY",
    Balancing_IssuedVouchersLCY: "Balancing_IssuedVouchersLCY",
    Balancing_Other: "Balancing_Other",
    Balancing_RoundingLCY: "Balancing_RoundingLCY",
    Balancing_BinTransferOutAmountLCY: "Balancing_BinTransferOutAmountLCY",
    Balancing_BinTransferInAmountLCY: "Balancing_BinTransferInAmountLCY",
    Balancing_CreditSales: "Balancing_CreditSales",
    Balancing_creditSalesCount: "Balancing_creditSalesCount",
    Balancing_CreditSalesAmountLCY: "Balancing_CreditSalesAmountLCY",
    Balancing_CreditNetSalesAmountLCY: "Balancing_CreditNetSalesAmountLCY",
    Balancing_Details: "Balancing_Details",
    Balancing_CreditUnrealSaleAmtLCY: "Balancing_CreditUnrealSaleAmtLCY",
    Balancing_CreditUnrealRetAmtLCY: "Balancing_CreditUnrealRetAmtLCY",
    Balancing_CreditRealSaleAmtLCY: "Balancing_CreditRealSaleAmtLCY",
    Balancing_CreditRealReturnAmtLCY: "Balancing_CreditRealReturnAmtLCY",
    Balancing_Discount: "Balancing_Discount",
    Balancing_DiscountAmounts: "Balancing_DiscountAmounts",
    Balancing_CampaignDiscountLCY: "Balancing_CampaignDiscountLCY",
    Balancing_MixDiscountLCY: "Balancing_MixDiscountLCY",
    Balancing_QuantityDiscountLCY: "Balancing_QuantityDiscountLCY",
    Balancing_CustomDiscountLCY: "Balancing_CustomDiscountLCY",
    Balancing_BOMDiscountLCY: "Balancing_BOMDiscountLCY",
    Balancing_CustomerDiscountLCY: "Balancing_CustomerDiscountLCY",
    Balancing_LineDiscountLCY: "Balancing_LineDiscountLCY",
    Balancing_DiscountPercent: "Balancing_DiscountPercent",
    Balancing_CampaignDiscountPct: "Balancing_CampaignDiscountPct",
    Balancing_MixDiscountPct: "Balancing_MixDiscountPct",
    Balancing_QuantityDiscountPct: "Balancing_QuantityDiscountPct",
    Balancing_CustomDiscountPct: "Balancing_CustomDiscountPct",
    Balancing_BOMDiscountPct: "Balancing_BOMDiscountPct",
    Balancing_CustomerDiscountPct: "Balancing_CustomerDiscountPct",
    Balancing_LineDiscountPct: "Balancing_LineDiscountPct",
    Balancing_DiscountTotal: "Balancing_DiscountTotal",
    Balancing_TotalDiscountLCY: "Balancing_TotalDiscountLCY",
    Balancing_TotalDiscountPct: "Balancing_TotalDiscountPct",
    Balancing_Turnover: "Balancing_Turnover",
    Balancing_TurnoverLCY: "Balancing_TurnoverLCY",
    Balancing_NetTurnoverLCY: "Balancing_NetTurnoverLCY",
    Balancing_NetCostLCY: "Balancing_NetCostLCY",
    Balancing_Profit: "Balancing_Profit",
    Balancing_ProfitAmountLCY: "Balancing_ProfitAmountLCY",
    Balancing_ProfitPct: "Balancing_ProfitPct",
    Balancing_Direct: "Balancing_Direct",
    Balancing_DirectTurnoverLCY: "Balancing_DirectTurnoverLCY",
    Balancing_DirectNetTurnoverLCY: "Balancing_DirectNetTurnoverLCY",
    Balancing_Credit: "Balancing_Credit",
    Balancing_CreditTurnoverLCY: "Balancing_CreditTurnoverLCY",
    Balancing_CreditNetTurnoverLCY: "Balancing_CreditNetTurnoverLCY",
    Balancing_TaxIdentifier: "Balancing_TaxIdentifier",
    Balancing_TaxPct: "Balancing_TaxPct",
    Balancing_TaxBaseAmount: "Balancing_TaxBaseAmount",
    Balancing_TaxAmount: "Balancing_TaxAmount",
    Balancing_AmountIncludingTax: "Balancing_AmountIncludingTax",
    Balancing_PaymentTypeNo: "Balancing_PaymentTypeNo",
    Balancing_Description: "Balancing_Description",
    Balancing_Difference: "Balancing_Difference",
    Balancing_CalculatedAmountInclFloat: "Balancing_CalculatedAmountInclFloat",
    Balancing_CountedAmountInclFloat: "Balancing_CountedAmountInclFloat",
    Balancing_FloatAmount: "Balancing_FloatAmount",
    Balancing_TransferredAmount: "Balancing_TransferredAmount",
    Balancing_NewFloatAmount: "Balancing_NewFloatAmount",
    Balancing_BankDepositAmount: "Balancing_BankDepositAmount",
    Balancing_BankDepositBinCode: "Balancing_BankDepositBinCode",
    Balancing_BankDepositReference: "Balancing_BankDepositReference",
    Balancing_MovetoBinAmount: "Balancing_MovetoBinAmount",
    Balancing_MovetoBinNo: "Balancing_MovetoBinNo",
    Balancing_MovetoBinTransID: "Balancing_MovetoBinTransID",
    Balancing_TaxSummary: "Balancing_TaxSummary",
    Balancing_ShowAll: "Balancing_ShowAll",
    CaptionDataGridSelected: "CaptionDataGridSelected",
    Lookup_Search: "Lookup_Search",
    Lookup_Caption: "Lookup_Caption",
    Lookup_New: "Lookup_New",
    Lookup_Card: "Lookup_Card",
    DialogCaption_Message: "DialogCaption_Message",
    DialogCaption_Confirmation: "DialogCaption_Confirmation",
    DialogCaption_Error: "DialogCaption_Error",
    DialogCaption_Numpad: "DialogCaption_Numpad",
    Locked_RegisterLocked: "Locked_RegisterLocked",
    CaptionTablet_ButtonItems: "CaptionTablet_ButtonItems",
    CaptionTablet_ButtonMore: "CaptionTablet_ButtonMore",
    CaptionTablet_ButtonPaymentMethods: "CaptionTablet_ButtonPaymentMethods",
    LastSale_Total: "LastSale_Total",
    LastSale_Paid: "LastSale_Paid",
    LastSale_Change: "LastSale_Change",
    Payment_SaleLCY: "Payment_SaleLCY",
    Payment_Paid: "Payment_Paid",
    Payment_Balance: "Payment_Balance",
  },
};

// TODO: all of these should be moved to AL captions set through SetCaptions
let _global = {
  [GlobalCaption.Input.InvalidValue]: "is not a valid value",
  [GlobalCaption.Input.ResultIs]: "Result is: ",
  [GlobalCaption.NotificationTooltips.BusyState.Busy]: "NAV is busy",
  [GlobalCaption.NotificationTooltips.BusyState.Idle]: "NAV is idle",
  [GlobalCaption.NotificationTooltips.Messages.NoMessages]: "No new notifications",
  [GlobalCaption.NotificationTooltips.Messages.MessagesAvailable]: "{0} new notifications",
  [GlobalCaption.Error]: "Error",
};

let _localization = {};

class LocalizationManager extends Component {
  render() {
    console.log(`[Dragonglass.LocalizationManager] Updating localization state`);
    const { localization } = this.props;
    _localization = { ..._global, ...(localization || {}) };
    return null;
  }
}

export default bindComponentToLocalizationStateFull(LocalizationManager);
export const localize = (caption) =>
  _localization[typeof caption === "string" && caption.startsWith("l$.") ? caption.substring(3) : caption] ||
  MISSING_CAPTION;
export const localizeAction = (action) => (_localization.Actions && _localization.Actions[action]) || {};
export const LocalizationHandler = { localize, localizeAction };
