package cz.uhk.pro2.tulipani.supabase;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
@EnableConfigurationProperties(SupabaseProperties.class)
public class SupabaseConfig {
	@Bean
	RestClient supabaseRestClient(RestClient.Builder builder, SupabaseProperties props) {
		var baseUrl = props.url();
		if (baseUrl == null || baseUrl.isBlank()) {
			throw new IllegalStateException("SUPABASE_URL is not set");
		}
		var key = props.serviceRoleKey();
		if (key == null || key.isBlank()) {
			throw new IllegalStateException("SUPABASE_SERVICE_ROLE_KEY is not set");
		}
		baseUrl = baseUrl.endsWith("/") ? baseUrl.substring(0, baseUrl.length() - 1) : baseUrl;

		return builder
				.baseUrl(baseUrl + "/rest/v1")
				.defaultHeader("apikey", key)
				.defaultHeader("Authorization", "Bearer " + key)
				.build();
	}
}
