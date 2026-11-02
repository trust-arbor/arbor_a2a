# Generated from A2A v1.0.1 (3303592588e388e62e0f69f701af531d2f4e3991).
# Upstream protocol: Apache-2.0; see priv/licenses/a2a-Apache-2.0.txt.
# Regenerate with scripts/generate_proto.py; do not edit by hand.
defmodule Arbor.A2A.Proto.Lf.A2a.V1.TaskState do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "lf.a2a.v1.TaskState",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "TaskState",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TASK_STATE_UNSPECIFIED",
          number: 0,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TASK_STATE_SUBMITTED",
          number: 1,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TASK_STATE_WORKING",
          number: 2,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TASK_STATE_COMPLETED",
          number: 3,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TASK_STATE_FAILED",
          number: 4,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TASK_STATE_CANCELED",
          number: 5,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TASK_STATE_INPUT_REQUIRED",
          number: 6,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TASK_STATE_REJECTED",
          number: 7,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "TASK_STATE_AUTH_REQUIRED",
          number: 8,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      options: nil,
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:TASK_STATE_UNSPECIFIED, 0)
  field(:TASK_STATE_SUBMITTED, 1)
  field(:TASK_STATE_WORKING, 2)
  field(:TASK_STATE_COMPLETED, 3)
  field(:TASK_STATE_FAILED, 4)
  field(:TASK_STATE_CANCELED, 5)
  field(:TASK_STATE_INPUT_REQUIRED, 6)
  field(:TASK_STATE_REJECTED, 7)
  field(:TASK_STATE_AUTH_REQUIRED, 8)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.Role do
  @moduledoc false

  use Protobuf,
    enum: true,
    full_name: "lf.a2a.v1.Role",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.EnumDescriptorProto{
      name: "Role",
      value: [
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "ROLE_UNSPECIFIED",
          number: 0,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "ROLE_USER",
          number: 1,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.EnumValueDescriptorProto{
          name: "ROLE_AGENT",
          number: 2,
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      options: nil,
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:ROLE_UNSPECIFIED, 0)
  field(:ROLE_USER, 1)
  field(:ROLE_AGENT, 2)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.SendMessageConfiguration do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.SendMessageConfiguration",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "SendMessageConfiguration",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "accepted_output_modes",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "acceptedOutputModes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "task_push_notification_config",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.TaskPushNotificationConfig",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "taskPushNotificationConfig",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "history_length",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "historyLength",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "return_immediately",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "returnImmediately",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_history_length",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:accepted_output_modes, 1,
    repeated: true,
    type: :string,
    json_name: "acceptedOutputModes"
  )

  field(:task_push_notification_config, 2,
    type: Arbor.A2A.Proto.Lf.A2a.V1.TaskPushNotificationConfig,
    json_name: "taskPushNotificationConfig"
  )

  field(:history_length, 3, proto3_optional: true, type: :int32, json_name: "historyLength")
  field(:return_immediately, 4, type: :bool, json_name: "returnImmediately")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.Task do
  @moduledoc false

  use Protobuf, full_name: "lf.a2a.v1.Task", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Task",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "context_id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "contextId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "status",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.TaskStatus",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "status",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "artifacts",
          extendee: nil,
          number: 4,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Artifact",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "artifacts",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "history",
          extendee: nil,
          number: 5,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Message",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "history",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:id, 1, type: :string, deprecated: false)
  field(:context_id, 2, type: :string, json_name: "contextId")
  field(:status, 3, type: Arbor.A2A.Proto.Lf.A2a.V1.TaskStatus, deprecated: false)
  field(:artifacts, 4, repeated: true, type: Arbor.A2A.Proto.Lf.A2a.V1.Artifact)
  field(:history, 5, repeated: true, type: Arbor.A2A.Proto.Lf.A2a.V1.Message)
  field(:metadata, 6, type: Google.Protobuf.Struct)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.TaskStatus do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.TaskStatus",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "TaskStatus",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "state",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".lf.a2a.v1.TaskState",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "state",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "message",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Message",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "message",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "timestamp",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Timestamp",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "timestamp",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:state, 1, type: Arbor.A2A.Proto.Lf.A2a.V1.TaskState, enum: true, deprecated: false)
  field(:message, 2, type: Arbor.A2A.Proto.Lf.A2a.V1.Message)
  field(:timestamp, 3, type: Google.Protobuf.Timestamp)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.Part do
  @moduledoc false

  use Protobuf, full_name: "lf.a2a.v1.Part", protoc_gen_elixir_version: "0.17.1", syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Part",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "text",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "text",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "raw",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BYTES,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "raw",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "url",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "url",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "data",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Value",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "data",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "filename",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "filename",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "media_type",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "mediaType",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "content",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  oneof(:content, 0)

  field(:text, 1, type: :string, oneof: 0)
  field(:raw, 2, type: :bytes, oneof: 0)
  field(:url, 3, type: :string, oneof: 0)
  field(:data, 4, type: Google.Protobuf.Value, oneof: 0)
  field(:metadata, 5, type: Google.Protobuf.Struct)
  field(:filename, 6, type: :string)
  field(:media_type, 7, type: :string, json_name: "mediaType")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.Message do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.Message",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Message",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "message_id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "messageId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "context_id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "contextId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "task_id",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "taskId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "role",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".lf.a2a.v1.Role",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "role",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "parts",
          extendee: nil,
          number: 5,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Part",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "parts",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "extensions",
          extendee: nil,
          number: 7,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "extensions",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "reference_task_ids",
          extendee: nil,
          number: 8,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "referenceTaskIds",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:message_id, 1, type: :string, json_name: "messageId", deprecated: false)
  field(:context_id, 2, type: :string, json_name: "contextId")
  field(:task_id, 3, type: :string, json_name: "taskId")
  field(:role, 4, type: Arbor.A2A.Proto.Lf.A2a.V1.Role, enum: true, deprecated: false)
  field(:parts, 5, repeated: true, type: Arbor.A2A.Proto.Lf.A2a.V1.Part, deprecated: false)
  field(:metadata, 6, type: Google.Protobuf.Struct)
  field(:extensions, 7, repeated: true, type: :string)
  field(:reference_task_ids, 8, repeated: true, type: :string, json_name: "referenceTaskIds")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.Artifact do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.Artifact",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "Artifact",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "artifact_id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "artifactId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "name",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "name",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "description",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "description",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "parts",
          extendee: nil,
          number: 4,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Part",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "parts",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "extensions",
          extendee: nil,
          number: 6,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "extensions",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:artifact_id, 1, type: :string, json_name: "artifactId", deprecated: false)
  field(:name, 2, type: :string)
  field(:description, 3, type: :string)
  field(:parts, 4, repeated: true, type: Arbor.A2A.Proto.Lf.A2a.V1.Part, deprecated: false)
  field(:metadata, 5, type: Google.Protobuf.Struct)
  field(:extensions, 6, repeated: true, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.TaskStatusUpdateEvent do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.TaskStatusUpdateEvent",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "TaskStatusUpdateEvent",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "task_id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "taskId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "context_id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "contextId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "status",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.TaskStatus",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "status",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:task_id, 1, type: :string, json_name: "taskId", deprecated: false)
  field(:context_id, 2, type: :string, json_name: "contextId", deprecated: false)
  field(:status, 3, type: Arbor.A2A.Proto.Lf.A2a.V1.TaskStatus, deprecated: false)
  field(:metadata, 4, type: Google.Protobuf.Struct)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.TaskArtifactUpdateEvent do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.TaskArtifactUpdateEvent",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "TaskArtifactUpdateEvent",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "task_id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "taskId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "context_id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "contextId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "artifact",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Artifact",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "artifact",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "append",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "append",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "last_chunk",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "lastChunk",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:task_id, 1, type: :string, json_name: "taskId", deprecated: false)
  field(:context_id, 2, type: :string, json_name: "contextId", deprecated: false)
  field(:artifact, 3, type: Arbor.A2A.Proto.Lf.A2a.V1.Artifact, deprecated: false)
  field(:append, 4, type: :bool)
  field(:last_chunk, 5, type: :bool, json_name: "lastChunk")
  field(:metadata, 6, type: Google.Protobuf.Struct)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AuthenticationInfo do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AuthenticationInfo",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "AuthenticationInfo",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "scheme",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "scheme",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "credentials",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "credentials",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:scheme, 1, type: :string, deprecated: false)
  field(:credentials, 2, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AgentInterface do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AgentInterface",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "AgentInterface",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "url",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "url",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "protocol_binding",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "protocolBinding",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "protocol_version",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "protocolVersion",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:url, 1, type: :string, deprecated: false)
  field(:protocol_binding, 2, type: :string, json_name: "protocolBinding", deprecated: false)
  field(:tenant, 3, type: :string)
  field(:protocol_version, 4, type: :string, json_name: "protocolVersion", deprecated: false)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AgentCard.SecuritySchemesEntry do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AgentCard.SecuritySchemesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "SecuritySchemesEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.SecurityScheme",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: Arbor.A2A.Proto.Lf.A2a.V1.SecurityScheme)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AgentCard do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AgentCard",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "AgentCard",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "name",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "name",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "description",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "description",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "supported_interfaces",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AgentInterface",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "supportedInterfaces",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "provider",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AgentProvider",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "provider",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "version",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "version",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "documentation_url",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "documentationUrl",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "capabilities",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AgentCapabilities",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "capabilities",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "security_schemes",
          extendee: nil,
          number: 8,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AgentCard.SecuritySchemesEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "securitySchemes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "security_requirements",
          extendee: nil,
          number: 9,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.SecurityRequirement",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "securityRequirements",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "default_input_modes",
          extendee: nil,
          number: 10,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "defaultInputModes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "default_output_modes",
          extendee: nil,
          number: 11,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "defaultOutputModes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "skills",
          extendee: nil,
          number: 12,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AgentSkill",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "skills",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "signatures",
          extendee: nil,
          number: 13,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AgentCardSignature",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "signatures",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "icon_url",
          extendee: nil,
          number: 14,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "iconUrl",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "SecuritySchemesEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".lf.a2a.v1.SecurityScheme",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_documentation_url",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_icon_url",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:name, 1, type: :string, deprecated: false)
  field(:description, 2, type: :string, deprecated: false)

  field(:supported_interfaces, 3,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.AgentInterface,
    json_name: "supportedInterfaces",
    deprecated: false
  )

  field(:provider, 4, type: Arbor.A2A.Proto.Lf.A2a.V1.AgentProvider)
  field(:version, 5, type: :string, deprecated: false)

  field(:documentation_url, 6,
    proto3_optional: true,
    type: :string,
    json_name: "documentationUrl"
  )

  field(:capabilities, 7, type: Arbor.A2A.Proto.Lf.A2a.V1.AgentCapabilities, deprecated: false)

  field(:security_schemes, 8,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.AgentCard.SecuritySchemesEntry,
    json_name: "securitySchemes",
    map: true
  )

  field(:security_requirements, 9,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.SecurityRequirement,
    json_name: "securityRequirements"
  )

  field(:default_input_modes, 10,
    repeated: true,
    type: :string,
    json_name: "defaultInputModes",
    deprecated: false
  )

  field(:default_output_modes, 11,
    repeated: true,
    type: :string,
    json_name: "defaultOutputModes",
    deprecated: false
  )

  field(:skills, 12,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.AgentSkill,
    deprecated: false
  )

  field(:signatures, 13, repeated: true, type: Arbor.A2A.Proto.Lf.A2a.V1.AgentCardSignature)
  field(:icon_url, 14, proto3_optional: true, type: :string, json_name: "iconUrl")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AgentProvider do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AgentProvider",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "AgentProvider",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "url",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "url",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "organization",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "organization",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:url, 1, type: :string, deprecated: false)
  field(:organization, 2, type: :string, deprecated: false)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AgentCapabilities do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AgentCapabilities",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "AgentCapabilities",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "streaming",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "streaming",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "push_notifications",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "pushNotifications",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "extensions",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AgentExtension",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "extensions",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "extended_agent_card",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "extendedAgentCard",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_streaming",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_push_notifications",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_extended_agent_card",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:streaming, 1, proto3_optional: true, type: :bool)

  field(:push_notifications, 2,
    proto3_optional: true,
    type: :bool,
    json_name: "pushNotifications"
  )

  field(:extensions, 3, repeated: true, type: Arbor.A2A.Proto.Lf.A2a.V1.AgentExtension)

  field(:extended_agent_card, 4,
    proto3_optional: true,
    type: :bool,
    json_name: "extendedAgentCard"
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AgentExtension do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AgentExtension",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "AgentExtension",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "uri",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "uri",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "description",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "description",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "required",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "required",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "params",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "params",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:uri, 1, type: :string)
  field(:description, 2, type: :string)
  field(:required, 3, type: :bool)
  field(:params, 4, type: Google.Protobuf.Struct)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AgentSkill do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AgentSkill",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "AgentSkill",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "name",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "name",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "description",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "description",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "tags",
          extendee: nil,
          number: 4,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "tags",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "examples",
          extendee: nil,
          number: 5,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "examples",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "input_modes",
          extendee: nil,
          number: 6,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "inputModes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "output_modes",
          extendee: nil,
          number: 7,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "outputModes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "security_requirements",
          extendee: nil,
          number: 8,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.SecurityRequirement",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "securityRequirements",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:id, 1, type: :string, deprecated: false)
  field(:name, 2, type: :string, deprecated: false)
  field(:description, 3, type: :string, deprecated: false)
  field(:tags, 4, repeated: true, type: :string, deprecated: false)
  field(:examples, 5, repeated: true, type: :string)
  field(:input_modes, 6, repeated: true, type: :string, json_name: "inputModes")
  field(:output_modes, 7, repeated: true, type: :string, json_name: "outputModes")

  field(:security_requirements, 8,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.SecurityRequirement,
    json_name: "securityRequirements"
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AgentCardSignature do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AgentCardSignature",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "AgentCardSignature",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "protected",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "protected",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "signature",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "signature",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "header",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "header",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:protected, 1, type: :string, deprecated: false)
  field(:signature, 2, type: :string, deprecated: false)
  field(:header, 3, type: Google.Protobuf.Struct)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.TaskPushNotificationConfig do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.TaskPushNotificationConfig",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "TaskPushNotificationConfig",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "task_id",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "taskId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "url",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "url",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "token",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "token",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "authentication",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AuthenticationInfo",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "authentication",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 1, type: :string)
  field(:id, 2, type: :string)
  field(:task_id, 3, type: :string, json_name: "taskId")
  field(:url, 4, type: :string, deprecated: false)
  field(:token, 5, type: :string)
  field(:authentication, 6, type: Arbor.A2A.Proto.Lf.A2a.V1.AuthenticationInfo)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.StringList do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.StringList",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "StringList",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "list",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "list",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:list, 1, repeated: true, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.SecurityRequirement.SchemesEntry do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.SecurityRequirement.SchemesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "SchemesEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.StringList",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: Arbor.A2A.Proto.Lf.A2a.V1.StringList)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.SecurityRequirement do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.SecurityRequirement",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "SecurityRequirement",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "schemes",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.SecurityRequirement.SchemesEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "schemes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "SchemesEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_MESSAGE,
              type_name: ".lf.a2a.v1.StringList",
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:schemes, 1,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.SecurityRequirement.SchemesEntry,
    map: true
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.SecurityScheme do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.SecurityScheme",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "SecurityScheme",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "api_key_security_scheme",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.APIKeySecurityScheme",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "apiKeySecurityScheme",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "http_auth_security_scheme",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.HTTPAuthSecurityScheme",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "httpAuthSecurityScheme",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "oauth2_security_scheme",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.OAuth2SecurityScheme",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "oauth2SecurityScheme",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "open_id_connect_security_scheme",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.OpenIdConnectSecurityScheme",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "openIdConnectSecurityScheme",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "mtls_security_scheme",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.MutualTlsSecurityScheme",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "mtlsSecurityScheme",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "scheme",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  oneof(:scheme, 0)

  field(:api_key_security_scheme, 1,
    type: Arbor.A2A.Proto.Lf.A2a.V1.APIKeySecurityScheme,
    json_name: "apiKeySecurityScheme",
    oneof: 0
  )

  field(:http_auth_security_scheme, 2,
    type: Arbor.A2A.Proto.Lf.A2a.V1.HTTPAuthSecurityScheme,
    json_name: "httpAuthSecurityScheme",
    oneof: 0
  )

  field(:oauth2_security_scheme, 3,
    type: Arbor.A2A.Proto.Lf.A2a.V1.OAuth2SecurityScheme,
    json_name: "oauth2SecurityScheme",
    oneof: 0
  )

  field(:open_id_connect_security_scheme, 4,
    type: Arbor.A2A.Proto.Lf.A2a.V1.OpenIdConnectSecurityScheme,
    json_name: "openIdConnectSecurityScheme",
    oneof: 0
  )

  field(:mtls_security_scheme, 5,
    type: Arbor.A2A.Proto.Lf.A2a.V1.MutualTlsSecurityScheme,
    json_name: "mtlsSecurityScheme",
    oneof: 0
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.APIKeySecurityScheme do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.APIKeySecurityScheme",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "APIKeySecurityScheme",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "description",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "description",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "location",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "location",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "name",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "name",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:description, 1, type: :string)
  field(:location, 2, type: :string, deprecated: false)
  field(:name, 3, type: :string, deprecated: false)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.HTTPAuthSecurityScheme do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.HTTPAuthSecurityScheme",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "HTTPAuthSecurityScheme",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "description",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "description",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "scheme",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "scheme",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "bearer_format",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "bearerFormat",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:description, 1, type: :string)
  field(:scheme, 2, type: :string, deprecated: false)
  field(:bearer_format, 3, type: :string, json_name: "bearerFormat")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.OAuth2SecurityScheme do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.OAuth2SecurityScheme",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "OAuth2SecurityScheme",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "description",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "description",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "flows",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.OAuthFlows",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "flows",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "oauth2_metadata_url",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "oauth2MetadataUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:description, 1, type: :string)
  field(:flows, 2, type: Arbor.A2A.Proto.Lf.A2a.V1.OAuthFlows, deprecated: false)
  field(:oauth2_metadata_url, 3, type: :string, json_name: "oauth2MetadataUrl")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.OpenIdConnectSecurityScheme do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.OpenIdConnectSecurityScheme",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "OpenIdConnectSecurityScheme",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "description",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "description",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "open_id_connect_url",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "openIdConnectUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:description, 1, type: :string)
  field(:open_id_connect_url, 2, type: :string, json_name: "openIdConnectUrl", deprecated: false)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.MutualTlsSecurityScheme do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.MutualTlsSecurityScheme",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "MutualTlsSecurityScheme",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "description",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "description",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:description, 1, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.OAuthFlows do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.OAuthFlows",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "OAuthFlows",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "authorization_code",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AuthorizationCodeOAuthFlow",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "authorizationCode",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "client_credentials",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.ClientCredentialsOAuthFlow",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "clientCredentials",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "implicit",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.ImplicitOAuthFlow",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: true,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_index: 0,
          json_name: "implicit",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "password",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.PasswordOAuthFlow",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: true,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_index: 0,
          json_name: "password",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "device_code",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.DeviceCodeOAuthFlow",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "deviceCode",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "flow",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  oneof(:flow, 0)

  field(:authorization_code, 1,
    type: Arbor.A2A.Proto.Lf.A2a.V1.AuthorizationCodeOAuthFlow,
    json_name: "authorizationCode",
    oneof: 0
  )

  field(:client_credentials, 2,
    type: Arbor.A2A.Proto.Lf.A2a.V1.ClientCredentialsOAuthFlow,
    json_name: "clientCredentials",
    oneof: 0
  )

  field(:implicit, 3,
    type: Arbor.A2A.Proto.Lf.A2a.V1.ImplicitOAuthFlow,
    oneof: 0,
    deprecated: true
  )

  field(:password, 4,
    type: Arbor.A2A.Proto.Lf.A2a.V1.PasswordOAuthFlow,
    oneof: 0,
    deprecated: true
  )

  field(:device_code, 5,
    type: Arbor.A2A.Proto.Lf.A2a.V1.DeviceCodeOAuthFlow,
    json_name: "deviceCode",
    oneof: 0
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AuthorizationCodeOAuthFlow.ScopesEntry do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AuthorizationCodeOAuthFlow.ScopesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ScopesEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.AuthorizationCodeOAuthFlow do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.AuthorizationCodeOAuthFlow",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "AuthorizationCodeOAuthFlow",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "authorization_url",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "authorizationUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "token_url",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "tokenUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "refresh_url",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "refreshUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "scopes",
          extendee: nil,
          number: 4,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.AuthorizationCodeOAuthFlow.ScopesEntry",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "scopes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "pkce_required",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "pkceRequired",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "ScopesEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:authorization_url, 1, type: :string, json_name: "authorizationUrl", deprecated: false)
  field(:token_url, 2, type: :string, json_name: "tokenUrl", deprecated: false)
  field(:refresh_url, 3, type: :string, json_name: "refreshUrl")

  field(:scopes, 4,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.AuthorizationCodeOAuthFlow.ScopesEntry,
    map: true,
    deprecated: false
  )

  field(:pkce_required, 5, type: :bool, json_name: "pkceRequired")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.ClientCredentialsOAuthFlow.ScopesEntry do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.ClientCredentialsOAuthFlow.ScopesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ScopesEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.ClientCredentialsOAuthFlow do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.ClientCredentialsOAuthFlow",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ClientCredentialsOAuthFlow",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "token_url",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "tokenUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "refresh_url",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "refreshUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "scopes",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.ClientCredentialsOAuthFlow.ScopesEntry",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "scopes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "ScopesEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:token_url, 1, type: :string, json_name: "tokenUrl", deprecated: false)
  field(:refresh_url, 2, type: :string, json_name: "refreshUrl")

  field(:scopes, 3,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.ClientCredentialsOAuthFlow.ScopesEntry,
    map: true,
    deprecated: false
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.ImplicitOAuthFlow.ScopesEntry do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.ImplicitOAuthFlow.ScopesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ScopesEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.ImplicitOAuthFlow do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.ImplicitOAuthFlow",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ImplicitOAuthFlow",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "authorization_url",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "authorizationUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "refresh_url",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "refreshUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "scopes",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.ImplicitOAuthFlow.ScopesEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "scopes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "ScopesEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:authorization_url, 1, type: :string, json_name: "authorizationUrl")
  field(:refresh_url, 2, type: :string, json_name: "refreshUrl")

  field(:scopes, 3,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.ImplicitOAuthFlow.ScopesEntry,
    map: true
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.PasswordOAuthFlow.ScopesEntry do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.PasswordOAuthFlow.ScopesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ScopesEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.PasswordOAuthFlow do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.PasswordOAuthFlow",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "PasswordOAuthFlow",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "token_url",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tokenUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "refresh_url",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "refreshUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "scopes",
          extendee: nil,
          number: 3,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.PasswordOAuthFlow.ScopesEntry",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "scopes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "ScopesEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:token_url, 1, type: :string, json_name: "tokenUrl")
  field(:refresh_url, 2, type: :string, json_name: "refreshUrl")

  field(:scopes, 3,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.PasswordOAuthFlow.ScopesEntry,
    map: true
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.DeviceCodeOAuthFlow.ScopesEntry do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.DeviceCodeOAuthFlow.ScopesEntry",
    map: true,
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ScopesEntry",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "key",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "key",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "value",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "value",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: %Google.Protobuf.MessageOptions{
        message_set_wire_format: false,
        no_standard_descriptor_accessor: false,
        deprecated: false,
        map_entry: true,
        deprecated_legacy_json_field_conflicts: nil,
        features: nil,
        uninterpreted_option: [],
        __pb_extensions__: %{},
        __unknown_fields__: [],
        __protobuf__: true
      },
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:key, 1, type: :string)
  field(:value, 2, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.DeviceCodeOAuthFlow do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.DeviceCodeOAuthFlow",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "DeviceCodeOAuthFlow",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "device_authorization_url",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "deviceAuthorizationUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "token_url",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "tokenUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "refresh_url",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "refreshUrl",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "scopes",
          extendee: nil,
          number: 4,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.DeviceCodeOAuthFlow.ScopesEntry",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "scopes",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [
        %Google.Protobuf.DescriptorProto{
          name: "ScopesEntry",
          field: [
            %Google.Protobuf.FieldDescriptorProto{
              name: "key",
              extendee: nil,
              number: 1,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "key",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            },
            %Google.Protobuf.FieldDescriptorProto{
              name: "value",
              extendee: nil,
              number: 2,
              label: :LABEL_OPTIONAL,
              type: :TYPE_STRING,
              type_name: nil,
              default_value: nil,
              options: nil,
              oneof_index: nil,
              json_name: "value",
              proto3_optional: nil,
              __unknown_fields__: [],
              __protobuf__: true
            }
          ],
          nested_type: [],
          enum_type: [],
          extension_range: [],
          extension: [],
          options: %Google.Protobuf.MessageOptions{
            message_set_wire_format: false,
            no_standard_descriptor_accessor: false,
            deprecated: false,
            map_entry: true,
            deprecated_legacy_json_field_conflicts: nil,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [],
            __protobuf__: true
          },
          oneof_decl: [],
          reserved_range: [],
          reserved_name: [],
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:device_authorization_url, 1,
    type: :string,
    json_name: "deviceAuthorizationUrl",
    deprecated: false
  )

  field(:token_url, 2, type: :string, json_name: "tokenUrl", deprecated: false)
  field(:refresh_url, 3, type: :string, json_name: "refreshUrl")

  field(:scopes, 4,
    repeated: true,
    type: Arbor.A2A.Proto.Lf.A2a.V1.DeviceCodeOAuthFlow.ScopesEntry,
    map: true,
    deprecated: false
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.SendMessageRequest do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.SendMessageRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "SendMessageRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "message",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Message",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "message",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "configuration",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.SendMessageConfiguration",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "configuration",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 1, type: :string)
  field(:message, 2, type: Arbor.A2A.Proto.Lf.A2a.V1.Message, deprecated: false)
  field(:configuration, 3, type: Arbor.A2A.Proto.Lf.A2a.V1.SendMessageConfiguration)
  field(:metadata, 4, type: Google.Protobuf.Struct)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.GetTaskRequest do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.GetTaskRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "GetTaskRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "history_length",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "historyLength",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_history_length",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 1, type: :string)
  field(:id, 2, type: :string, deprecated: false)
  field(:history_length, 3, proto3_optional: true, type: :int32, json_name: "historyLength")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.ListTasksRequest do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.ListTasksRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListTasksRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "context_id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "contextId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "status",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_ENUM,
          type_name: ".lf.a2a.v1.TaskState",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "status",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "page_size",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "pageSize",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "page_token",
          extendee: nil,
          number: 5,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "pageToken",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "history_length",
          extendee: nil,
          number: 6,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 1,
          json_name: "historyLength",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "status_timestamp_after",
          extendee: nil,
          number: 7,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Timestamp",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "statusTimestampAfter",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "include_artifacts",
          extendee: nil,
          number: 8,
          label: :LABEL_OPTIONAL,
          type: :TYPE_BOOL,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: 2,
          json_name: "includeArtifacts",
          proto3_optional: true,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "_page_size",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_history_length",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.OneofDescriptorProto{
          name: "_include_artifacts",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 1, type: :string)
  field(:context_id, 2, type: :string, json_name: "contextId")
  field(:status, 3, type: Arbor.A2A.Proto.Lf.A2a.V1.TaskState, enum: true)
  field(:page_size, 4, proto3_optional: true, type: :int32, json_name: "pageSize")
  field(:page_token, 5, type: :string, json_name: "pageToken")
  field(:history_length, 6, proto3_optional: true, type: :int32, json_name: "historyLength")

  field(:status_timestamp_after, 7,
    type: Google.Protobuf.Timestamp,
    json_name: "statusTimestampAfter"
  )

  field(:include_artifacts, 8, proto3_optional: true, type: :bool, json_name: "includeArtifacts")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.ListTasksResponse do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.ListTasksResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListTasksResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tasks",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Task",
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "tasks",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "next_page_token",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "nextPageToken",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "page_size",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "pageSize",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "total_size",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "totalSize",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tasks, 1, repeated: true, type: Arbor.A2A.Proto.Lf.A2a.V1.Task, deprecated: false)
  field(:next_page_token, 2, type: :string, json_name: "nextPageToken", deprecated: false)
  field(:page_size, 3, type: :int32, json_name: "pageSize", deprecated: false)
  field(:total_size, 4, type: :int32, json_name: "totalSize", deprecated: false)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.CancelTaskRequest do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.CancelTaskRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "CancelTaskRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "metadata",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".google.protobuf.Struct",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "metadata",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 1, type: :string)
  field(:id, 2, type: :string, deprecated: false)
  field(:metadata, 3, type: Google.Protobuf.Struct)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.GetTaskPushNotificationConfigRequest do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.GetTaskPushNotificationConfigRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "GetTaskPushNotificationConfigRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "task_id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "taskId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 1, type: :string)
  field(:task_id, 2, type: :string, json_name: "taskId", deprecated: false)
  field(:id, 3, type: :string, deprecated: false)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.DeleteTaskPushNotificationConfigRequest do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.DeleteTaskPushNotificationConfigRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "DeleteTaskPushNotificationConfigRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "task_id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "taskId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 1, type: :string)
  field(:task_id, 2, type: :string, json_name: "taskId", deprecated: false)
  field(:id, 3, type: :string, deprecated: false)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.SubscribeToTaskRequest do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.SubscribeToTaskRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "SubscribeToTaskRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "id",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "id",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 1, type: :string)
  field(:id, 2, type: :string, deprecated: false)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.ListTaskPushNotificationConfigsRequest do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.ListTaskPushNotificationConfigsRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListTaskPushNotificationConfigsRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "task_id",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: %Google.Protobuf.FieldOptions{
            ctype: :STRING,
            packed: nil,
            deprecated: false,
            lazy: false,
            jstype: :JS_NORMAL,
            weak: false,
            unverified_lazy: false,
            debug_redact: false,
            retention: nil,
            targets: [],
            edition_defaults: [],
            features: nil,
            feature_support: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [{1052, 2, <<2>>}],
            __protobuf__: true
          },
          oneof_index: nil,
          json_name: "taskId",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "page_size",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_INT32,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "pageSize",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "page_token",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "pageToken",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 4, type: :string)
  field(:task_id, 1, type: :string, json_name: "taskId", deprecated: false)
  field(:page_size, 2, type: :int32, json_name: "pageSize")
  field(:page_token, 3, type: :string, json_name: "pageToken")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.GetExtendedAgentCardRequest do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.GetExtendedAgentCardRequest",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "GetExtendedAgentCardRequest",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "tenant",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "tenant",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:tenant, 1, type: :string)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.SendMessageResponse do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.SendMessageResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "SendMessageResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "task",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Task",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "task",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "message",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Message",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "message",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "payload",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  oneof(:payload, 0)

  field(:task, 1, type: Arbor.A2A.Proto.Lf.A2a.V1.Task, oneof: 0)
  field(:message, 2, type: Arbor.A2A.Proto.Lf.A2a.V1.Message, oneof: 0)
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.StreamResponse do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.StreamResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "StreamResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "task",
          extendee: nil,
          number: 1,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Task",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "task",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "message",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.Message",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "message",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "status_update",
          extendee: nil,
          number: 3,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.TaskStatusUpdateEvent",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "statusUpdate",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "artifact_update",
          extendee: nil,
          number: 4,
          label: :LABEL_OPTIONAL,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.TaskArtifactUpdateEvent",
          default_value: nil,
          options: nil,
          oneof_index: 0,
          json_name: "artifactUpdate",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [
        %Google.Protobuf.OneofDescriptorProto{
          name: "payload",
          options: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  oneof(:payload, 0)

  field(:task, 1, type: Arbor.A2A.Proto.Lf.A2a.V1.Task, oneof: 0)
  field(:message, 2, type: Arbor.A2A.Proto.Lf.A2a.V1.Message, oneof: 0)

  field(:status_update, 3,
    type: Arbor.A2A.Proto.Lf.A2a.V1.TaskStatusUpdateEvent,
    json_name: "statusUpdate",
    oneof: 0
  )

  field(:artifact_update, 4,
    type: Arbor.A2A.Proto.Lf.A2a.V1.TaskArtifactUpdateEvent,
    json_name: "artifactUpdate",
    oneof: 0
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.ListTaskPushNotificationConfigsResponse do
  @moduledoc false

  use Protobuf,
    full_name: "lf.a2a.v1.ListTaskPushNotificationConfigsResponse",
    protoc_gen_elixir_version: "0.17.1",
    syntax: :proto3

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.DescriptorProto{
      name: "ListTaskPushNotificationConfigsResponse",
      field: [
        %Google.Protobuf.FieldDescriptorProto{
          name: "configs",
          extendee: nil,
          number: 1,
          label: :LABEL_REPEATED,
          type: :TYPE_MESSAGE,
          type_name: ".lf.a2a.v1.TaskPushNotificationConfig",
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "configs",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.FieldDescriptorProto{
          name: "next_page_token",
          extendee: nil,
          number: 2,
          label: :LABEL_OPTIONAL,
          type: :TYPE_STRING,
          type_name: nil,
          default_value: nil,
          options: nil,
          oneof_index: nil,
          json_name: "nextPageToken",
          proto3_optional: nil,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      nested_type: [],
      enum_type: [],
      extension_range: [],
      extension: [],
      options: nil,
      oneof_decl: [],
      reserved_range: [],
      reserved_name: [],
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  field(:configs, 1, repeated: true, type: Arbor.A2A.Proto.Lf.A2a.V1.TaskPushNotificationConfig)
  field(:next_page_token, 2, type: :string, json_name: "nextPageToken")
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.A2AService.Service do
  @moduledoc false

  use GRPC.Service, name: "lf.a2a.v1.A2AService", protoc_gen_elixir_version: "0.17.1"

  def descriptor do
    # credo:disable-for-next-line
    %Google.Protobuf.ServiceDescriptorProto{
      name: "A2AService",
      method: [
        %Google.Protobuf.MethodDescriptorProto{
          name: "SendMessage",
          input_type: ".lf.a2a.v1.SendMessageRequest",
          output_type: ".lf.a2a.v1.SendMessageResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {72_295_728, 2,
               <<34, 13, 47, 109, 101, 115, 115, 97, 103, 101, 58, 115, 101, 110, 100, 58, 1, 42,
                 90, 27, 34, 22, 47, 123, 116, 101, 110, 97, 110, 116, 125, 47, 109, 101, 115,
                 115, 97, 103, 101, 58, 115, 101, 110, 100, 58, 1, 42>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "SendStreamingMessage",
          input_type: ".lf.a2a.v1.SendMessageRequest",
          output_type: ".lf.a2a.v1.StreamResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {72_295_728, 2,
               <<34, 15, 47, 109, 101, 115, 115, 97, 103, 101, 58, 115, 116, 114, 101, 97, 109,
                 58, 1, 42, 90, 29, 34, 24, 47, 123, 116, 101, 110, 97, 110, 116, 125, 47, 109,
                 101, 115, 115, 97, 103, 101, 58, 115, 116, 114, 101, 97, 109, 58, 1, 42>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "GetTask",
          input_type: ".lf.a2a.v1.GetTaskRequest",
          output_type: ".lf.a2a.v1.Task",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {1051, 2, "id"},
              {72_295_728, 2,
               <<18, 13, 47, 116, 97, 115, 107, 115, 47, 123, 105, 100, 61, 42, 125, 90, 24, 18,
                 22, 47, 123, 116, 101, 110, 97, 110, 116, 125, 47, 116, 97, 115, 107, 115, 47,
                 123, 105, 100, 61, 42, 125>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "ListTasks",
          input_type: ".lf.a2a.v1.ListTasksRequest",
          output_type: ".lf.a2a.v1.ListTasksResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {72_295_728, 2,
               <<18, 6, 47, 116, 97, 115, 107, 115, 90, 17, 18, 15, 47, 123, 116, 101, 110, 97,
                 110, 116, 125, 47, 116, 97, 115, 107, 115>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "CancelTask",
          input_type: ".lf.a2a.v1.CancelTaskRequest",
          output_type: ".lf.a2a.v1.Task",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {72_295_728, 2,
               <<34, 20, 47, 116, 97, 115, 107, 115, 47, 123, 105, 100, 61, 42, 125, 58, 99, 97,
                 110, 99, 101, 108, 58, 1, 42, 90, 34, 34, 29, 47, 123, 116, 101, 110, 97, 110,
                 116, 125, 47, 116, 97, 115, 107, 115, 47, 123, 105, 100, 61, 42, 125, 58, 99, 97,
                 110, 99, 101, 108, 58, 1, 42>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "SubscribeToTask",
          input_type: ".lf.a2a.v1.SubscribeToTaskRequest",
          output_type: ".lf.a2a.v1.StreamResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {72_295_728, 2,
               <<18, 23, 47, 116, 97, 115, 107, 115, 47, 123, 105, 100, 61, 42, 125, 58, 115, 117,
                 98, 115, 99, 114, 105, 98, 101, 90, 34, 18, 32, 47, 123, 116, 101, 110, 97, 110,
                 116, 125, 47, 116, 97, 115, 107, 115, 47, 123, 105, 100, 61, 42, 125, 58, 115,
                 117, 98, 115, 99, 114, 105, 98, 101>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: true,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "CreateTaskPushNotificationConfig",
          input_type: ".lf.a2a.v1.TaskPushNotificationConfig",
          output_type: ".lf.a2a.v1.TaskPushNotificationConfig",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {1051, 2, "task_id,config"},
              {72_295_728, 2,
               <<34, 42, 47, 116, 97, 115, 107, 115, 47, 123, 116, 97, 115, 107, 95, 105, 100, 61,
                 42, 125, 47, 112, 117, 115, 104, 78, 111, 116, 105, 102, 105, 99, 97, 116, 105,
                 111, 110, 67, 111, 110, 102, 105, 103, 115, 58, 1, 42, 90, 56, 34, 51, 47, 123,
                 116, 101, 110, 97, 110, 116, 125, 47, 116, 97, 115, 107, 115, 47, 123, 116, 97,
                 115, 107, 95, 105, 100, 61, 42, 125, 47, 112, 117, 115, 104, 78, 111, 116, 105,
                 102, 105, 99, 97, 116, 105, 111, 110, 67, 111, 110, 102, 105, 103, 115, 58, 1,
                 42>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "GetTaskPushNotificationConfig",
          input_type: ".lf.a2a.v1.GetTaskPushNotificationConfigRequest",
          output_type: ".lf.a2a.v1.TaskPushNotificationConfig",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {1051, 2, "task_id,id"},
              {72_295_728, 2,
               <<18, 49, 47, 116, 97, 115, 107, 115, 47, 123, 116, 97, 115, 107, 95, 105, 100, 61,
                 42, 125, 47, 112, 117, 115, 104, 78, 111, 116, 105, 102, 105, 99, 97, 116, 105,
                 111, 110, 67, 111, 110, 102, 105, 103, 115, 47, 123, 105, 100, 61, 42, 125, 90,
                 60, 18, 58, 47, 123, 116, 101, 110, 97, 110, 116, 125, 47, 116, 97, 115, 107,
                 115, 47, 123, 116, 97, 115, 107, 95, 105, 100, 61, 42, 125, 47, 112, 117, 115,
                 104, 78, 111, 116, 105, 102, 105, 99, 97, 116, 105, 111, 110, 67, 111, 110, 102,
                 105, 103, 115, 47, 123, 105, 100, 61, 42, 125>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "ListTaskPushNotificationConfigs",
          input_type: ".lf.a2a.v1.ListTaskPushNotificationConfigsRequest",
          output_type: ".lf.a2a.v1.ListTaskPushNotificationConfigsResponse",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {1051, 2, "task_id"},
              {72_295_728, 2,
               <<18, 42, 47, 116, 97, 115, 107, 115, 47, 123, 116, 97, 115, 107, 95, 105, 100, 61,
                 42, 125, 47, 112, 117, 115, 104, 78, 111, 116, 105, 102, 105, 99, 97, 116, 105,
                 111, 110, 67, 111, 110, 102, 105, 103, 115, 90, 53, 18, 51, 47, 123, 116, 101,
                 110, 97, 110, 116, 125, 47, 116, 97, 115, 107, 115, 47, 123, 116, 97, 115, 107,
                 95, 105, 100, 61, 42, 125, 47, 112, 117, 115, 104, 78, 111, 116, 105, 102, 105,
                 99, 97, 116, 105, 111, 110, 67, 111, 110, 102, 105, 103, 115>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "GetExtendedAgentCard",
          input_type: ".lf.a2a.v1.GetExtendedAgentCardRequest",
          output_type: ".lf.a2a.v1.AgentCard",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {72_295_728, 2,
               <<18, 18, 47, 101, 120, 116, 101, 110, 100, 101, 100, 65, 103, 101, 110, 116, 67,
                 97, 114, 100, 90, 29, 18, 27, 47, 123, 116, 101, 110, 97, 110, 116, 125, 47, 101,
                 120, 116, 101, 110, 100, 101, 100, 65, 103, 101, 110, 116, 67, 97, 114, 100>>}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        },
        %Google.Protobuf.MethodDescriptorProto{
          name: "DeleteTaskPushNotificationConfig",
          input_type: ".lf.a2a.v1.DeleteTaskPushNotificationConfigRequest",
          output_type: ".google.protobuf.Empty",
          options: %Google.Protobuf.MethodOptions{
            deprecated: false,
            idempotency_level: :IDEMPOTENCY_UNKNOWN,
            features: nil,
            uninterpreted_option: [],
            __pb_extensions__: %{},
            __unknown_fields__: [
              {1051, 2, "task_id,id"},
              {72_295_728, 2,
               "*1/tasks/{task_id=*}/pushNotificationConfigs/{id=*}Z<*:/{tenant}/tasks/{task_id=*}/pushNotificationConfigs/{id=*}"}
            ],
            __protobuf__: true
          },
          client_streaming: false,
          server_streaming: false,
          __unknown_fields__: [],
          __protobuf__: true
        }
      ],
      options: nil,
      __unknown_fields__: [],
      __protobuf__: true
    }
  end

  rpc(
    :SendMessage,
    Arbor.A2A.Proto.Lf.A2a.V1.SendMessageRequest,
    Arbor.A2A.Proto.Lf.A2a.V1.SendMessageResponse
  )

  rpc(
    :SendStreamingMessage,
    Arbor.A2A.Proto.Lf.A2a.V1.SendMessageRequest,
    stream(Arbor.A2A.Proto.Lf.A2a.V1.StreamResponse)
  )

  rpc(:GetTask, Arbor.A2A.Proto.Lf.A2a.V1.GetTaskRequest, Arbor.A2A.Proto.Lf.A2a.V1.Task)

  rpc(
    :ListTasks,
    Arbor.A2A.Proto.Lf.A2a.V1.ListTasksRequest,
    Arbor.A2A.Proto.Lf.A2a.V1.ListTasksResponse
  )

  rpc(:CancelTask, Arbor.A2A.Proto.Lf.A2a.V1.CancelTaskRequest, Arbor.A2A.Proto.Lf.A2a.V1.Task)

  rpc(
    :SubscribeToTask,
    Arbor.A2A.Proto.Lf.A2a.V1.SubscribeToTaskRequest,
    stream(Arbor.A2A.Proto.Lf.A2a.V1.StreamResponse)
  )

  rpc(
    :CreateTaskPushNotificationConfig,
    Arbor.A2A.Proto.Lf.A2a.V1.TaskPushNotificationConfig,
    Arbor.A2A.Proto.Lf.A2a.V1.TaskPushNotificationConfig
  )

  rpc(
    :GetTaskPushNotificationConfig,
    Arbor.A2A.Proto.Lf.A2a.V1.GetTaskPushNotificationConfigRequest,
    Arbor.A2A.Proto.Lf.A2a.V1.TaskPushNotificationConfig
  )

  rpc(
    :ListTaskPushNotificationConfigs,
    Arbor.A2A.Proto.Lf.A2a.V1.ListTaskPushNotificationConfigsRequest,
    Arbor.A2A.Proto.Lf.A2a.V1.ListTaskPushNotificationConfigsResponse
  )

  rpc(
    :GetExtendedAgentCard,
    Arbor.A2A.Proto.Lf.A2a.V1.GetExtendedAgentCardRequest,
    Arbor.A2A.Proto.Lf.A2a.V1.AgentCard
  )

  rpc(
    :DeleteTaskPushNotificationConfig,
    Arbor.A2A.Proto.Lf.A2a.V1.DeleteTaskPushNotificationConfigRequest,
    Google.Protobuf.Empty
  )
end

defmodule Arbor.A2A.Proto.Lf.A2a.V1.A2AService.Stub do
  @moduledoc false

  use GRPC.Stub, service: Arbor.A2A.Proto.Lf.A2a.V1.A2AService.Service
end
