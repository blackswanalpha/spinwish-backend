package com.spinwish.backend.services;

import com.spinwish.backend.entities.payments.RequestsPayment;
import com.spinwish.backend.entities.payments.TipPayments;
import com.spinwish.backend.exceptions.PaymentException;
import com.spinwish.backend.repositories.ArtistRepository;
import com.spinwish.backend.repositories.SongRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Service for generating payment receipts
 */
@Service
@Slf4j
public class ReceiptService {

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

    @Autowired
    private SongRepository songRepository;

    @Autowired
    private ArtistRepository artistRepository;

    /**
     * Generate receipt data for a request payment
     */
    public Map<String, Object> generateRequestPaymentReceipt(RequestsPayment payment) {
        if (payment == null) {
            throw new PaymentException("Payment cannot be null");
        }

        Map<String, Object> receiptData = new HashMap<>();
        receiptData.put("type", "SONG_REQUEST");
        receiptData.put("receiptNumber", payment.getReceiptNumber());
        receiptData.put("payerName", payment.getPayerName());
        receiptData.put("phoneNumber", formatPhoneNumber(payment.getPhoneNumber()));
        receiptData.put("amount", String.format("KES %.2f", payment.getAmount()));
        receiptData.put("transactionDate", payment.getTransactionDate().format(DATE_FORMATTER));
        receiptData.put("description", "Song Request Payment");
        
        if (payment.getRequest() != null) {
            // Get song information from songId
            String songId = payment.getRequest().getSongId();
            if (songId != null) {
                try {
                    UUID songUuid = UUID.fromString(songId);
                    songRepository.findById(songUuid).ifPresent(song -> {
                        receiptData.put("songTitle", song.getName());
                        receiptData.put("songAlbum", song.getAlbum());

                        // Get artist information
                        if (song.getArtistId() != null) {
                            artistRepository.findById(song.getArtistId()).ifPresent(artist -> {
                                receiptData.put("artistName", artist.getName());
                            });
                        }
                    });
                } catch (IllegalArgumentException e) {
                    log.warn("Invalid song ID format: {}", songId);
                    receiptData.put("songTitle", "Unknown Song");
                    receiptData.put("artistName", "Unknown Artist");
                }
            }

            if (payment.getRequest().getMessage() != null) {
                receiptData.put("message", payment.getRequest().getMessage());
            }
        }

        receiptData.put("businessName", "SpinWish");
        receiptData.put("businessContact", "support@spinwish.com");
        receiptData.put("generatedAt", java.time.LocalDateTime.now().format(DATE_FORMATTER));

        log.info("Generated receipt data for request payment: {}", payment.getReceiptNumber());
        return receiptData;
    }

    /**
     * Generate receipt data for a tip payment
     */
    public Map<String, Object> generateTipPaymentReceipt(TipPayments payment) {
        if (payment == null) {
            throw new PaymentException("Payment cannot be null");
        }

        Map<String, Object> receiptData = new HashMap<>();
        receiptData.put("type", "TIP");
        receiptData.put("receiptNumber", payment.getReceiptNumber());
        receiptData.put("payerName", payment.getPayerName());
        receiptData.put("phoneNumber", formatPhoneNumber(payment.getPhoneNumber()));
        receiptData.put("amount", String.format("KES %.2f", payment.getAmount()));
        receiptData.put("transactionDate", payment.getTransactionDate().format(DATE_FORMATTER));
        receiptData.put("description", "DJ Tip Payment");
        
        if (payment.getDj() != null) {
            receiptData.put("djName", payment.getDj().getActualUsername());
            receiptData.put("djEmail", payment.getDj().getEmailAddress());
        }

        receiptData.put("businessName", "SpinWish");
        receiptData.put("businessContact", "support@spinwish.com");
        receiptData.put("generatedAt", java.time.LocalDateTime.now().format(DATE_FORMATTER));

        log.info("Generated receipt data for tip payment: {}", payment.getReceiptNumber());
        return receiptData;
    }

    /**
     * Generate HTML receipt content
     */
    public String generateHtmlReceipt(Map<String, Object> receiptData) {
        StringBuilder html = new StringBuilder();
        
        html.append("<!DOCTYPE html>");
        html.append("<html><head>");
        html.append("<meta charset='UTF-8'>");
        html.append("<title>SpinWish Payment Receipt</title>");
        html.append("<style>");
        html.append("body { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; }");
        html.append(".header { text-align: center; border-bottom: 2px solid #333; padding-bottom: 20px; margin-bottom: 20px; }");
        html.append(".logo { font-size: 24px; font-weight: bold; color: #6366f1; }");
        html.append(".receipt-info { margin-bottom: 20px; }");
        html.append(".info-row { display: flex; justify-content: space-between; margin-bottom: 10px; }");
        html.append(".label { font-weight: bold; }");
        html.append(".amount { font-size: 18px; font-weight: bold; color: #059669; }");
        html.append(".footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ccc; font-size: 12px; color: #666; }");
        html.append("</style>");
        html.append("</head><body>");

        // Header
        html.append("<div class='header'>");
        html.append("<div class='logo'>").append(receiptData.get("businessName")).append("</div>");
        html.append("<p>Payment Receipt</p>");
        html.append("</div>");

        // Receipt details
        html.append("<div class='receipt-info'>");
        html.append("<div class='info-row'>");
        html.append("<span class='label'>Receipt Number:</span>");
        html.append("<span>").append(receiptData.get("receiptNumber")).append("</span>");
        html.append("</div>");

        html.append("<div class='info-row'>");
        html.append("<span class='label'>Transaction Date:</span>");
        html.append("<span>").append(receiptData.get("transactionDate")).append("</span>");
        html.append("</div>");

        html.append("<div class='info-row'>");
        html.append("<span class='label'>Payer Name:</span>");
        html.append("<span>").append(receiptData.get("payerName")).append("</span>");
        html.append("</div>");

        html.append("<div class='info-row'>");
        html.append("<span class='label'>Phone Number:</span>");
        html.append("<span>").append(receiptData.get("phoneNumber")).append("</span>");
        html.append("</div>");

        html.append("<div class='info-row'>");
        html.append("<span class='label'>Description:</span>");
        html.append("<span>").append(receiptData.get("description")).append("</span>");
        html.append("</div>");

        // Type-specific details
        if ("SONG_REQUEST".equals(receiptData.get("type"))) {
            if (receiptData.containsKey("songTitle")) {
                html.append("<div class='info-row'>");
                html.append("<span class='label'>Song:</span>");
                html.append("<span>").append(receiptData.get("songTitle"));
                if (receiptData.containsKey("artistName")) {
                    html.append(" by ").append(receiptData.get("artistName"));
                }
                html.append("</span></div>");
            }
            if (receiptData.containsKey("message")) {
                html.append("<div class='info-row'>");
                html.append("<span class='label'>Message:</span>");
                html.append("<span>").append(receiptData.get("message")).append("</span>");
                html.append("</div>");
            }
        } else if ("TIP".equals(receiptData.get("type"))) {
            if (receiptData.containsKey("djName")) {
                html.append("<div class='info-row'>");
                html.append("<span class='label'>DJ:</span>");
                html.append("<span>").append(receiptData.get("djName")).append("</span>");
                html.append("</div>");
            }
        }

        // Amount
        html.append("<div class='info-row'>");
        html.append("<span class='label'>Amount:</span>");
        html.append("<span class='amount'>").append(receiptData.get("amount")).append("</span>");
        html.append("</div>");

        html.append("</div>");

        // Footer
        html.append("<div class='footer'>");
        html.append("<p>Thank you for using SpinWish!</p>");
        html.append("<p>Contact: ").append(receiptData.get("businessContact")).append("</p>");
        html.append("<p>Generated on: ").append(receiptData.get("generatedAt")).append("</p>");
        html.append("</div>");

        html.append("</body></html>");

        return html.toString();
    }

    /**
     * Format phone number for display
     */
    private String formatPhoneNumber(String phoneNumber) {
        if (phoneNumber == null || phoneNumber.length() != 12) {
            return phoneNumber;
        }
        
        // Format 254XXXXXXXXX to +254 XXX XXX XXX
        return String.format("+%s %s %s %s",
            phoneNumber.substring(0, 3),
            phoneNumber.substring(3, 6),
            phoneNumber.substring(6, 9),
            phoneNumber.substring(9, 12)
        );
    }
}
