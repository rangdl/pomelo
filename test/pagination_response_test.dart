import 'package:flutter_test/flutter_test.dart';
import 'package:pomelo/core/pagination/pagination_response.dart';

/// 替换前各音源手写的 total 表达式，用于校验工厂改写后行为等价
int legacyTotal(int itemCount, int page, int limit) =>
    itemCount < limit ? (page - 1) * limit + itemCount : page * limit + 1;

void main() {
  group('PaginationResponse.fromTotal', () {
    test('服务端已知总数时按总数推断 hasMore', () {
      final r = PaginationResponse.fromTotal(
        items: List.filled(20, 'x'),
        page: 1,
        limit: 20,
        total: 57,
      );
      expect(r.page, 1);
      expect(r.limit, 20);
      expect(r.total, 57);
      expect(r.hasMore, isTrue);
      expect(r.items.length, 20);
    });

    test('最后一页 hasMore 为 false', () {
      final r = PaginationResponse.fromTotal(
        items: List.filled(17, 'x'),
        page: 3,
        limit: 20,
        total: 57,
      );
      expect(r.hasMore, isFalse);
    });

    test('恰好整除的末页不再声称有下一页', () {
      final r = PaginationResponse.fromTotal(
        items: List.filled(20, 'x'),
        page: 3,
        limit: 20,
        total: 60,
      );
      expect(r.hasMore, isFalse);
    });
  });

  group('PaginationResponse.fromPageSize', () {
    test('取满一页则假定还有更多', () {
      final r = PaginationResponse.fromPageSize(
        items: List.filled(20, 'x'),
        page: 2,
        limit: 20,
      );
      expect(r.hasMore, isTrue);
      expect(r.total, 41); // 已知至少 2*20+1
    });

    test('未取满一页则到此为止', () {
      final r = PaginationResponse.fromPageSize(
        items: List.filled(7, 'x'),
        page: 2,
        limit: 20,
      );
      expect(r.hasMore, isFalse);
      expect(r.total, 27); // 前一页 20 + 本页 7
    });

    test('空页', () {
      final r = PaginationResponse.fromPageSize(
        items: <String>[],
        page: 1,
        limit: 20,
      );
      expect(r.hasMore, isFalse);
      expect(r.total, 0);
      expect(r.items, isEmpty);
    });

    test('total 与替换前的手写表达式逐一等价', () {
      for (final page in [1, 2, 5]) {
        for (final limit in [1, 10, 20]) {
          for (var count = 0; count <= limit; count++) {
            final r = PaginationResponse.fromPageSize(
              items: List.filled(count, 'x'),
              page: page,
              limit: limit,
            );
            expect(
              r.total,
              legacyTotal(count, page, limit),
              reason: 'page=$page limit=$limit count=$count',
            );
            expect(r.hasMore, count == limit);
          }
        }
      }
    });
  });

  group('PaginationResponse.complete', () {
    test('默认按单页全量', () {
      final r = PaginationResponse.complete(List.filled(5, 'x'));
      expect(r.page, 1);
      expect(r.limit, 5);
      expect(r.total, 5);
      expect(r.hasMore, isFalse);
    });

    test('回显调用方传入的分页参数但不产生下一页', () {
      final r = PaginationResponse.complete(
        List.filled(5, 'x'),
        page: 3,
        limit: 20,
      );
      expect(r.page, 3);
      expect(r.limit, 20);
      expect(r.total, 5);
      expect(r.hasMore, isFalse);
    });
  });
}
