import bucket.{type BucketError, type Credentials}
import bucket/internal
import gleam/bit_array
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/option.{type Option}
import gleam/string_tree
import xmb

/// The parameters for the API request
pub type RequestBuilder {
  RequestBuilder(name: String, region: Option(String))
}

pub fn request(name name: String) -> RequestBuilder {
  RequestBuilder(name:, region: option.None)
}

/// The region to create the bucket in. Defaults to the region from the
/// credentials if no region is specifier.
///
pub fn region(builder: RequestBuilder, region: String) -> RequestBuilder {
  RequestBuilder(..builder, region: option.Some(region))
}

pub fn build(builder: RequestBuilder, creds: Credentials) -> Request(BitArray) {
  let body =
    xmb.x(
      "CreateBucketConfiguration",
      [#("xmlns", "http://s3.amazonaws.com/doc/2006-03-01/")],
      [
        xmb.x("LocationConstraint", [], [
          xmb.text(option.unwrap(builder.region, creds.region)),
        ]),
      ],
    )
    |> xmb.render_fragment
    |> string_tree.to_string
    |> bit_array.from_string
  internal.request(creds, http.Put, "/" <> builder.name, [], [], body)
}

pub fn response(response: Response(BitArray)) -> Result(Nil, BucketError) {
  case response.status {
    200 -> Ok(Nil)
    _ -> internal.s3_error(response)
  }
}
