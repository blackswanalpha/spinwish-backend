package com.spinwish.backend.models.responses.payments;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

@Data
public class MpesaQueryResponse {

    @JsonProperty("ResponseCode")
    private String responseCode;

    @JsonProperty("ResponseDescription")
    private String responseDescription;

    @JsonProperty("MerchantRequestID")
    private String merchantRequestId;

    @JsonProperty("CheckoutRequestID")
    private String checkoutRequestID;

    @JsonProperty("ResultCode")
    private int resultCode;

    @JsonProperty("ResultDesc")
    private String resultDesc;

    @JsonProperty("Amount")
    private Double amount;

    @JsonProperty("MpesaReceiptNumber")
    private String mpesaReceiptNumber;

    @JsonProperty("TransactionDate")
    private String transactionDate;

    @JsonProperty("PhoneNumber")
    private String phoneNumber;
}

