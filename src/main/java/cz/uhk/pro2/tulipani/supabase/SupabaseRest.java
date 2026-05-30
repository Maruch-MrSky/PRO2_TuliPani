package cz.uhk.pro2.tulipani.supabase;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

@Component
public class SupabaseRest {
	private static final String PGRST_OBJECT = "application/vnd.pgrst.object+json";

	private final RestClient restClient;
	private final ObjectMapper objectMapper;

	public SupabaseRest(RestClient restClient, ObjectMapper objectMapper) {
		this.restClient = restClient;
		this.objectMapper = objectMapper;
	}

	public <T> T getObject(String pathAndQuery, Class<T> type) {
		try {
			return restClient.get()
					.uri(pathAndQuery)
					.accept(MediaType.valueOf(PGRST_OBJECT))
					.retrieve()
					.body(type);
		} catch (RestClientResponseException ex) {
			if (ex.getRawStatusCode() == 404) {
				return null;
			}
			throw ex;
		}
	}

	public <T> List<T> getList(String pathAndQuery, TypeReference<List<T>> typeRef) {
		var body = restClient.get()
				.uri(pathAndQuery)
				.accept(MediaType.APPLICATION_JSON)
				.retrieve()
				.body(String.class);

		try {
			return objectMapper.readValue(body, typeRef);
		} catch (Exception e) {
			throw new IllegalStateException("Failed to parse Supabase response", e);
		}
	}

	public <T> T insertReturning(String table, Object payload, Class<T> objectType) {
		var body = restClient.post()
				.uri("/" + table)
				.contentType(MediaType.APPLICATION_JSON)
				.accept(MediaType.APPLICATION_JSON)
				.header("Prefer", "return=representation")
				.body(payload)
				.retrieve()
				.body(String.class);
		try {
			var listType = objectMapper.getTypeFactory().constructCollectionType(List.class, objectType);
			List<T> list = objectMapper.readValue(body, listType);
			return list.isEmpty() ? null : list.getFirst();
		} catch (Exception e) {
			throw new IllegalStateException("Failed to parse Supabase insert response", e);
		}
	}

	public <T> T patchReturning(String table, String filterQuery, Object payload, Class<T> objectType) {
		var body = restClient.patch()
				.uri("/" + table + "?" + filterQuery)
				.contentType(MediaType.APPLICATION_JSON)
				.accept(MediaType.APPLICATION_JSON)
				.header("Prefer", "return=representation")
				.body(payload)
				.retrieve()
				.body(String.class);
		try {
			var listType = objectMapper.getTypeFactory().constructCollectionType(List.class, objectType);
			List<T> list = objectMapper.readValue(body, listType);
			return list.isEmpty() ? null : list.getFirst();
		} catch (Exception e) {
			throw new IllegalStateException("Failed to parse Supabase patch response", e);
		}
	}

	public void delete(String table, String filterQuery) {
		restClient.delete()
				.uri("/" + table + "?" + filterQuery)
				.header("Prefer", "return=minimal")
				.retrieve()
				.toBodilessEntity();
	}

	public static String enc(String value) {
		return URLEncoder.encode(value, StandardCharsets.UTF_8);
	}
}
