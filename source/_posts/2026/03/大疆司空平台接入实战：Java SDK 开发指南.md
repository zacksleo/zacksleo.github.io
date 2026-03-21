---
title: 大疆司空平台接入实战：Java SDK 开发指南
date: 2026-03-17 13:47:27
tags: [大疆司空, 大疆机场, 无人机, Java, OpenAPI]
---

# 大疆司空平台接入实战：Java SDK 开发指南

## 前言

大疆司空 2（DJI FlightHub 2）是大疆创新推出的一款**无人机任务管理平台**，支持航线规划、任务调度、实时指挥和数据管理等功能。通过其开放的 **OpenAPI** 接口，开发者可以将无人机巡检、航拍等能力集成到自有业务系统中。

在电力巡检、光伏巡检、智慧城市测绘等场景中，企业通常需要将大疆司空的能力与自有业务系统深度整合，实现自动化作业流程。本文将基于实际项目开发经验，详细介绍如何通过 Java 接入大疆司空 2 平台，涵盖认证方式、核心 API 调用、Webhook 事件处理等关键内容。

> 如果你在接入过程中遇到 **403 无权限异常**，可以先阅读姊妹篇：[大疆司空平台接入实战：OpenAPI 403无权限异常排查](/2026/03/大疆司空平台接入实战：OpenAPI无权限异常排查.html)

## 一、开发环境准备

### 1.1 前置依赖

开发大疆司空 SDK 需要准备以下环境：

| 依赖项 | 版本要求 | 说明 |
|--------|----------|------|
| JDK | 1.8+ | Java 开发环境 |
| OkHttp | 4.10.0+ | HTTP 客户端 |
| Jackson | 2.15+ | JSON 处理 |
| Lombok | 1.18+ | 简化代码编写 |

### 1.2 Maven 依赖配置

```xml
<dependencies>
    <dependency>
        <groupId>com.squareup.okhttp3</groupId>
        <artifactId>okhttp</artifactId>
        <version>4.12.0</version>
    </dependency>
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.15.4</version>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.30</version>
        <scope>provided</scope>
    </dependency>
</dependencies>
```

### 1.3 获取开发者权限

接入大疆司空 OpenAPI 需要以下步骤：

1. 注册大疆开发者账号：访问 [大疆开发者平台](https://developer.dji.com/) 注册账号
2. 创建企业组织：在大疆司空控制台创建企业组织
3. 创建应用：申请 OpenAPI 权限并获取 AppKey
4. 生成 Token：由项目管理员生成访问令牌

> 提示：Token 必须由项目管理员生成，普通成员生成的 Token 无法调用 API。

## 二、认证方式

大疆司空 2 API 采用基于 Token 的认证机制，主要支持两种方式：

### 1. X-User-Token（推荐）

```java
DjiFlightSdk sdk = new DjiFlightSdk("your-user-token");
```

适用于绝大部分接口，推荐优先使用。

### 2. X-User-Token + X-Organization-Key

```java
DjiFlightSdk sdk = new DjiFlightSdk("your-user-token", "your-organization-key");
```

组织级认证，适用于跨组织资源访问场景。

## 三、SDK 核心架构设计

### 3.1 基础类设计

```java
@Slf4j
public class DjiFlightSdk {
    private static final String BASE_URL = "https://es-flight-api-cn.djigate.com";
    private static final String HEADER_USER_TOKEN = "X-User-Token";
    private static final String HEADER_ORG_KEY = "X-Organization-Key";
    private static final String HEADER_PROJECT_UUID = "X-Project-Uuid";

    private final OkHttpClient client;
    private final ObjectMapper objectMapper;
    private String userToken;
    private String organizationKey;

    public DjiFlightSdk(String userToken) {
        this(userToken, null);
    }

    public DjiFlightSdk(String userToken, String organizationKey) {
        this.userToken = userToken;
        this.organizationKey = organizationKey;
        this.client = buildOkHttpClient();
        this.objectMapper = buildObjectMapper();
    }
}
```

关键组件：

- **OkHttpClient**：处理 HTTP 请求，配置 30 秒超时和请求/响应日志拦截器
- **ObjectMapper**：处理 JSON 序列化，支持 snake_case 到 camelCase 的自动映射
- **请求头管理**：统一处理认证头和项目头

### 3.2 HTTP 客户端配置

```java
private OkHttpClient buildOkHttpClient() {
    HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor();
    interceptor.setLevel(HttpLoggingInterceptor.Level.BODY);
    return new OkHttpClient.Builder()
        .connectTimeout(Duration.ofSeconds(30))
        .readTimeout(Duration.ofSeconds(30))
        .writeTimeout(Duration.ofSeconds(30))
        .addInterceptor(interceptor)
        .build();
}

private ObjectMapper buildObjectMapper() {
    ObjectMapper mapper = new ObjectMapper();
    mapper.setPropertyNamingStrategy(
        PropertyNamingStrategies.SNAKE_CASE_TO_CAMEL_CASE
    );
    return mapper;
}
```

### 3.3 响应解析

大疆司空 2 API 响应格式统一为：

```json
{
  "code": 0,
  "message": "",
  "data": { ... }
}
```

SDK 提供两种解析方法：

```java
// 适用于创建任务等嵌套结构
private <T> T parseResponse(Response response, Class<T> clazz)
    throws IOException {
    String body = response.body().string();
    JsonNode node = objectMapper.readTree(body);
    return objectMapper.treeToValue(node.get("data"), clazz);
}

// 适用于列表等扁平结构
private <T> T parseSimpleResponse(Response response, Class<T> clazz)
    throws IOException {
    String body = response.body().string();
    return objectMapper.readValue(body, clazz);
}
```

## 四、请求头封装

### 4.1 认证头处理

```java
private Request.Builder addAuthHeaders(Request.Builder builder) {
    builder.addHeader(HEADER_USER_TOKEN, userToken);
    if (organizationKey != null && !organizationKey.isEmpty()) {
        builder.addHeader(HEADER_ORG_KEY, organizationKey);
    }
    return builder;
}
```

### 4.2 项目头处理

对于项目相关的 API，需要在请求头中添加 `X-Project-Uuid`：

```java
public ProjectListResponse getProjectList() throws IOException {
    HttpUrl url = HttpUrl.parse(BASE_URL)
        .newBuilder()
        .addPathSegment("openapi")
        .addPathSegment("v0.1")
        .addPathSegment("project")
        .build();

    Request request = addAuthHeaders(new Request.Builder())
        .url(url)
        .get()
        .build();

    Response response = client.newCall(request).execute();
    return parseResponse(response, ProjectListResponse.class);
}
```

## 五、核心 API 实现

### 1. 创建飞行任务

```java
public CreateTaskResponse createFlightTask(String projectUuid, CreateTaskRequest request)
```

**关键参数说明：**

| 字段 | 类型 | 说明 | 枚举值 |
|------|------|------|--------|
| taskType | String | 任务类型 | immediate, timed, recurring, continuous |
| rthMode | String | 返航模式 | intelligent, fixed |
| waylinePrecisionType | String | 任务精度 | gps, rtk |
| outOfControlActionInFlight | String | 失联动作 | lost_connection, continue_flight |
| resumableStatus | String | 断点续飞 | auto, manual |

**特别注意：** 所有枚举值在 V1.0 API 中均为**String 类型**，而非早期版本的 Integer 类型。

**使用示例：**

```java
CreateTaskRequest req = CreateTaskRequest.builder()
    .name("园区巡检任务")
    .sn("机场 SN")
    .waylineUuid("航线 UUID")
    .timeZone("Asia/Shanghai")
    .rthAltitude(50)
    .rthMode("fixed")
    .waylinePrecisionType("rtk")
    .outOfControlActionInFlight("lost_connection")
    .resumableStatus("auto")
    .taskType("immediate")
    .build();

CreateTaskResponse resp = sdk.createFlightTask("项目 UUID", req);
```

### 2. 获取项目列表

```java
public ProjectListResponse getProjectList()
```

通过 `X-User-Token` 自动获取当前组织下所有项目。

### 5.3 获取航线列表

```java
public WaylineListResponse getWaylineList(String projectUuid) throws IOException {
    HttpUrl url = HttpUrl.parse(BASE_URL)
        .newBuilder()
        .addPathSegment("openapi")
        .addPathSegment("v0.1")
        .addPathSegment("wayline")
        .build();

    Request request = addAuthHeaders(new Request.Builder())
        .addHeader(HEADER_PROJECT_UUID, projectUuid)
        .url(url)
        .get()
        .build();

    Response response = client.newCall(request).execute();
    return parseResponse(response, WaylineListResponse.class);
}
```

**航线类型说明：**

| 类型 | 说明 | 应用场景 |
|------|------|----------|
| waypoint | 航点航线 | 电力巡检、定点拍照 |
| mapping_2d | 正射采集（建图航拍） | 二维地图重建 |
| mapping_3d | 倾斜摄影 | 三维模型重建 |
| mapping_strip | 带状航线 | 公路、河道巡检 |
| facade | 斜面航线 | 建筑立面测量 |
| solid | 几何体航线 | 大型建筑物三维建模 |
| mapping_gobject | 贴近摄影 | 精细结构采集 |

**负载镜头类型：**

- **wide** - 广角镜头，适用于大面积测绘
- **zoom** - 变焦镜头，适用于远距离细节检查
- **ir** - 红外镜头，适用于电力巡检发热检测

## 六、任务启动与状态查询

### 6.1 创建飞行任务

```java
public CreateTaskResponse createFlightTask(String projectUuid, CreateTaskRequest request)
```

**关键参数说明：**

| 字段 | 类型 | 说明 | 枚举值 |
|------|------|------|--------|
| taskType | String | 任务类型 | immediate, timed, recurring, continuous |
| rthMode | String | 返航模式 | intelligent, fixed |
| waylinePrecisionType | String | 任务精度 | gps, rtk |
| outOfControlActionInFlight | String | 失联动作 | lost_connection, continue_flight |
| resumableStatus | String | 断点续飞 | auto, manual |

**特别注意：** 所有枚举值在 V1.0 API 中均为**String 类型**，而非早期版本的 Integer 类型。

**使用示例：**

```java
CreateTaskRequest req = CreateTaskRequest.builder()
    .name("园区巡检任务")
    .sn("机场 SN")
    .waylineUuid("航线 UUID")
    .timeZone("Asia/Shanghai")
    .rthAltitude(50)
    .rthMode("fixed")
    .waylinePrecisionType("rtk")
    .outOfControlActionInFlight("lost_connection")
    .resumableStatus("auto")
    .taskType("immediate")
    .build();

CreateTaskResponse resp = sdk.createFlightTask("项目 UUID", req);
```

### 6.2 查询任务状态

```java
public TaskStatusResponse getTaskStatus(String projectUuid, String taskUuid)
```

通过该接口可以实时查询任务的执行状态、当前进度、剩余电量等信息。

## 七、Webhook 事件处理

大疆司空 2 支持推送多种事件通知，SDK 封装了完整的事件解析和处理逻辑。

### 支持的事件类型

| notify_type | 事件说明 |
|-------------|----------|
| flighttask_progress | 任务执行进度/状态变更 |
| drc_file_upload_complete | 指令任务媒体上传完成 |
| way_line_file_upload_complete | 航线任务媒体上传完成 |
| file_uploaded | 航线文件/3D 模型上传完成 |
| device_exit_return_home | 退出返航通知 |

### 任务状态码

| 状态码 | 含义 |
|--------|------|
| 0 | 待执行 |
| 2 | 执行中 |
| 4 | 终止 |
| 5 | 成功 |

### 使用示例

```java
@PostMapping("/dji/webhook")
public void handle(@RequestBody String json) throws Exception {
    DjiWebhookHandler handler = new DjiWebhookHandler();
    WebhookEvent event = handler.parseEvent(json);

    if (event instanceof FlightTaskProgressEvent p) {
        if (p.isCompleted()) {
            log.info("任务完成：{}", p.getName());
        } else if (p.isRunning()) {
            log.info("任务执行中：{}/{}", p.getName(), p.getCurrentWaypointIndex());
        }
    }
}
```

### 7.3 完整业务处理示例

```java
@PostMapping("/dji/webhook")
public void handle(@RequestBody String json) throws Exception {
    DjiWebhookHandler handler = new DjiWebhookHandler();
    WebhookEvent event = handler.parseEvent(json);

    if (event instanceof FlightTaskProgressEvent p) {
        if (p.isCompleted()) {
            log.info("任务完成：{}", p.getName());
            // 任务完成后触发后续业务流程
            businessService.processTaskCompletion(p);
        } else if (p.isRunning()) {
            log.info("任务执行中：{}/{}", p.getName(), p.getCurrentWaypointIndex());
            // 更新前端任务进度
            websocketService.sendProgressUpdate(p);
        }
    }
}
```

## 八、数据类型与请求模型

### 8.1 坐标格式

大疆司空 API 使用 **WGS84 坐标系**，经纬度格式如下：

```java
@Data
public class Coordinate {
    private Double latitude;  // 纬度，范围 -90 ~ 90
    private Double longitude; // 经度，范围 -180 ~ 180
    private Double altitude;  // 高度，单位米
}
```

### 8.2 航点参数

```java
@Data
public class Waypoint {
    private Coordinate coordinate;
    private Double speed;
    private Double gimbalPitch;
    private Integer actionTime;
    private List<WaypointAction> actions;
}
```

## 九、常见问题排查

### 9.1 403 Forbidden

**现象：** 调用 API 返回 403

**原因：** Token 权限不足或项目 UUID 错误

**解决方法：**

1. 确认 Token 有效且具有对应 API 的访问权限
2. 检查 `X-Project-Uuid` 头是否正确携带
3. 验证 Token 创建人仍然在项目成员列表中
4. 尝试由项目管理员重新生成 Token

> 详细排查步骤请参考：[大疆OpenAPI 403无权限异常排查指南](/2026/03/大疆openapi-403无权限异常排查指南.html)

### 9.2 404 Not Found

**现象：** 请求路径不存在

**原因：** API 版本变更导致路径错误

**解决：** 使用正确的 V1.0 API 路径：

| 接口 | 正确路径 |
|------|----------|
| 项目列表 | `/openapi/v0.1/project` |
| 航线列表 | `/openapi/v0.1/wayline` |
| 创建任务 | `/openapi/v0.1/flight-task` |

### 9.3 字段类型错误

**现象：** 请求被拒绝或返回参数错误

**原因：** 使用了旧的 Integer 枚举值

**解决：** 确保所有枚举字段使用 String 类型，如 `"rtk"` 而非 `1`

## 十、最佳实践

### 10.1 异常封装

在实际项目中，建议对 API 调用进行统一的异常封装：

```java
public class DjiApiException extends RuntimeException {
    private Integer code;
    private String message;

    public DjiApiException(Integer code, String message) {
        super(message);
        this.code = code;
        this.message = message;
    }
}
```

### 10.2 连接池优化

对于高并发场景，建议调整 OkHttp 连接池参数：

```java
connectionPool(new ConnectionPool(10, 5, TimeUnit.MINUTES))
```

## 总结

接入大疆司空 2 平台开发业务系统，需要注意以下关键点：

**开发准备阶段：**
1. 确认开发环境和依赖版本
2. 由项目管理员生成正确的 Token
3. 测试获取项目列表接口验证认证

**开发集成阶段：**
1. **认证方式**：优先使用 X-User-Token
2. **API 版本**：统一使用 V1.0 接口，枚举值为 String 类型
3. **请求头**：项目相关 API 需添加 X-Project-Uuid
4. **Webhook**：处理事件通知实现任务状态异步更新

通过合理的 SDK 封装，可以大大简化集成工作，让业务代码专注于核心逻辑而非 HTTP 细节。后续我会继续分享更多大疆司空开发实战技巧，包括航线上传、媒体文件下载等高级功能，敬请关注。

> 如果这篇文章对你有帮助，欢迎点赞👍、收藏⭐、关注🔔，你的支持是我持续创作的动力！

---

**相关资源：**

- [大疆开发者平台](https://developer.dji.com/)
- [大疆司空官网](https://www.dji.com/cn/flighthub-2)
- [全新司空 2 OpenAPI V1.0 文档](https://s.apifox.cn/6b4ca90b-233f-48ac-818c-d694acb0663a)
- [大疆司空平台接入实战：OpenAPI 403无权限异常排查](/2026/03/大疆司空OpenAPI无权限异常排查指南.html)
