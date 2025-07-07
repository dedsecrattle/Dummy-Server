use axum::{
    routing::get,
    response::Json,
    Router,
};
use serde_json::Value;
use std::{fs, net::SocketAddr, sync::Arc};
use tokio::net::TcpListener;

#[tokio::main]
async fn main() {
    // Load your JSON once when the server starts
    let file_content = fs::read_to_string("data/variants.json")
        .expect("Failed to read JSON file");

    let parsed_json: Value = serde_json::from_str(&file_content)
        .expect("Failed to parse JSON");

    // Wrap in Arc for thread safety
    let shared_json = Arc::new(parsed_json);

    // Build app
    let app = Router::new().route(
        "/variants",
        get({
            let shared_json = Arc::clone(&shared_json);
            move || {
                let data = Arc::clone(&shared_json);
                async move { Json(data.as_ref().clone()) }
            }
        }),
    );

    let addr = SocketAddr::from(([127, 0, 0, 1], 9090));
    println!("Listening on http://{}", addr);
    
    let listener = TcpListener::bind(&addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}