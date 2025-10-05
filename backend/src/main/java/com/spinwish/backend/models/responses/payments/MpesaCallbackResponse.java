package com.spinwish.backend.models.responses.payments;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import java.util.List;

@Data
public class MpesaCallbackResponse {
    @JsonProperty("Body")
    private Body body;

    @Data
    public static class Body {
        @JsonProperty("stkCallback")
        private StkCallback stkCallback;

        @Data
        public static class StkCallback {
            @JsonProperty("ResultCode")
            private int resultCode;

            @JsonProperty("ResultDesc")
            private String resultDesc;

            @JsonProperty("MerchantRequestID")
            private String merchantRequestID;

            @JsonProperty("CheckoutRequestID")
            private String checkoutRequestID;

            @JsonProperty("CallbackMetadata")
            private CallbackMetadata callbackMetadata;

            @Data
            public static class CallbackMetadata {
                @JsonProperty("Item")
                private List<Item> item;

                @Data
                public static class Item {
                    @JsonProperty("Name")
                    private String name;

                    @JsonProperty("Value")
                    private Object value;

                    // ✅ Add constructor for easier instantiation
                    public Item(String name, Object value) {
                        this.name = name;
                        this.value = value;
                    }

                    // No-arg constructor (required for deserialization)
                    public Item() {}
                }
            }
        }
    }
}
